require 'sqlite3'
require 'singleton'
require_relative 'users.rb'
require_relative 'questions.rb'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionLike

  def self.likers_for_question(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_likes
    JOIN
      users ON users.id = question_likes.user_id
    WHERE
      question_id = ?
    SQL
    return nil if likers.empty?
    likers.map{|user| User.new(user)}
  end

  def self.num_likes_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_likes
    JOIN
      users ON users.id = question_likes.user_id
    WHERE
      question_id = ?
    SQL
    likers.length
  end

  def self.liked_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.user_id
      FROM
        question_likes
      JOIN
        users ON users.id = question_likes.user_id
      JOIN
        questions ON questions.id = question_likes.question_id
      WHERE
        users.id = ?
    SQL
    return nil if questions.empty?
    questions.map {|q| Question.new(q)}
  end

  def self.most_liked_questions(n)
    most_liked = QuestionsDatabase.instance.execute(<<-SQL, n)
    SELECT
      questions.id, questions.title, questions.body, questions.user_id
    FROM
      question_likes
    JOIN
      questions ON questions.id = question_likes.question_id
    GROUP BY
      questions.id
    ORDER BY
      COUNT(*) DESC
    LIMIT ?
    SQL
    return nil if most_liked.empty?
    most_liked.map {|q| Question.new(q)}
  end
end
