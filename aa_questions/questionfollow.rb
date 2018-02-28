require_relative 'question.rb'
require_relative 'user.rb'

class QuestionFollow
  attr_reader :id, :user_id, :question_id

  def self.all
    follows = QuestionDBConnection.instance.execute("SELECT * FROM question_follows")
    follows.map { |follow| QuestionFollow.new(follow) }
  end

  def self.find_by_id(id)
    follows = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    return nil unless follows.length > 0 # person is stored in an array!

    follows.map { |follow| QuestionFollow.new(follow) }
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN users
        ON question_follows.user_id = users.id
        WHERE question_id = ?
    SQL
  end

  def self.followed_questions_for_user_id(user_id)
    followers = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
        WHERE question_follows.user_id = ?
    SQL
  end

  def self.most_followed_questions(n)
    questions = QuestionDBConnection.instance.execute(<<-SQL)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN questions
        ON question_follows.question_id = questions.id
      ORDER BY question_id ASC
        LIMIT #{n}
    SQL
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDBConnection.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @id, @user_id, @question_id)
      UPDATE
        question_follows
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end

end
