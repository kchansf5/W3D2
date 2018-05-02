require 'sqlite3'
require 'singleton'
require_relative 'questions.rb'
require_relative 'reply'
require_relative 'questionfollows.rb'
require_relative 'question_like.rb'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class User
  attr_accessor :fname, :lname

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL

    return nil if user.empty?

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def authored_questions
    Question.find_by_author(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    average = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        -- CAST( COUNT( case when question_likes.user_id is null then 0 else 1 end) / COUNT( DISTINCT(questions.id) ) AS FLOAT)
        CAST( COUNT(question_likes.id) AS FLOAT) / COUNT(DISTINCT(questions.id)) AS avg_karma
      FROM
        questions
      LEFT OUTER JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        questions.user_id = ?
      -- GROUP BY
      --   question_id
    SQL


  end

end
