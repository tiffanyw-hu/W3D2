require_relative 'user.rb'
require_relative 'question.rb'

class Reply
  attr_accessor :body, :parent_id
  attr_reader :id, :user_id, :question_id

  def self.all
    replies = QuestionDBConnection.instance.execute("SELECT * FROM replies")
    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_user_id(user_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless replies.length > 0 # person is stored in an array!

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_by_question_id(question_id)
    replies = QuestionDBConnection.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    return nil unless replies.length > 0 # person is stored in an array!

    replies.map { |reply| Reply.new(reply) }
  end

  def self.find_body_by_parent(parent_id)
    bodies = QuestionDBConnection.instance.execute(<<-SQL, parent_id)
      SELECT
        body
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    return nil unless bodies.length > 0 # person is stored in an array!

    bodies.map { |body| Reply.new(body) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @parent_id = options['parent_id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_question_id(question_id)
  end

  def parent_reply
    Reply.find_body_by_parent(@parent_id)
  end

  def create
    raise "#{self} already in database" if @id
    QuestionDBConnection.instance.execute(<<-SQL, @body, @parent_id, @user_id, @question_id)
      INSERT INTO
        replies (body, parent_id, user_id, question_id)
      VALUES
        (?, ?, ?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @id, @body, @parent_id, @user_id, @question_id)
      UPDATE
        replies
      SET
        body = ?, parent_id = ?, user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end
end
