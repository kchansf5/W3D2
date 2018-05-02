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

class QuestionFollow

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      users.id, users.fname, users.lname
    FROM
      question_follows
    JOIN
      users ON users.id = question_follows.user_id
    WHERE
      question_follows.question_id = ?
    SQL
    return nil if followers.empty?
    followers.map {|follower| User.new(follower)}
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
    SELECT
      questions.id, questions.title, questions.body, questions.user_id
    FROM
      question_follows
    JOIN
      users ON users.id = question_follows.user_id
    JOIN
      questions ON question_follows.question_id = questions.id
    WHERE
      users.id = ?
    SQL
    return nil if questions.empty?
    questions.map {|question| Question.new(question)}
  end

  def self.most_followed_questions(n)
    most_followed = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.id, questions.title, questions.body, questions.user_id
      FROM
        question_follows
      JOIN
        users ON users.id = question_follows.user_id
      JOIN
        questions ON question_follows.question_id = questions.id
      GROUP BY question_id
      ORDER BY COUNT(*) DESC
      LIMIT (?)
    SQL

    return nil if most_followed.empty?
    most_followed.map {|mf| Question.new(mf)}
  end

end
