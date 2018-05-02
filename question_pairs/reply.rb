require 'sqlite3'
require 'singleton'
require_relative 'questions.rb'
require_relative 'users.rb'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class Reply
  attr_reader :question_id, :user_id, :parent_reply_id
  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil if reply.empty?
    reply.map {|r| Reply.new(r)}
  end

  def self.find_by_parent_reply_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    return nil if reply.empty?
    Reply.new(reply.first)
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil if reply.empty?
    reply.map {|r| Reply.new(r)}
  end

  def initialize(option)
    @id = option['id']
    @question_id = option['question_id']
    @user_id = option['user_id']
    @parent_reply_id = option['parent_reply_id']
    @body = option['body']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @parent_reply_id, @body)
      INSERT INTO
        replies (question_id, user_id, parent_reply_id, body)
      VALUES
        (?, ?, ? ,?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @body)
      UPDATE
        replies (body)
      SET
        body = ?
      WHERE
        id = ?
    SQL
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(question_id)
  end

  def parent_reply
    Reply.find_by_parent_reply_id(parent_reply_id)
  end

  def child_replies
    child = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL

    Reply.new(child.first)
  end


end
