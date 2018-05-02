require 'sqlite3'
require 'singleton'
require_relative 'users.rb'
require_relative 'question_like.rb'


class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question

attr_reader :user_id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_author(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
      SQL
      return nil if question.empty?
      Question.new(question.first)
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
      SQL
      return nil if question.empty?
      Question.new(question.first)
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body)
      UPDATE
        questions
      SET
        title = ?, body = ?
      WHERE
        id = ?
    SQL
  end

  def author
    User.find_by_id(user_id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed(n)
  end

  def likers
    QuestionLike.likers_for_question(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end


end
