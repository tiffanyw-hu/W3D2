

class QuestionLike

  attr_reader :id, :user_id, :question_id

  def self.all
    likes = QuestionDBConnection.instance.execute("SELECT * FROM question_likes")
    likes.map { |like| QuestionLike.new(like) }
  end

  def self.find_by_id(id)
    likes = QuestionDBConnection.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    return nil unless likes.length > 0 # person is stored in an array!

    likes.map { |like| QuestionLike.new(like) }
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      users.*
    FROM
        question_likes
    JOIN users
      ON question_likes.user_id = users.id
      WHERE question_id = ?
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
    users = QuestionDBConnection.instance.execute(<<-SQL, user_id)
    SELECT
      questions.*
    FROM
      question_likes
    JOIN questions
      ON question_likes.user_id = users.id
      WHERE question_id = ?
    SQL
  end

  def self.num_likes_for_question(question_id)
    likes = QuestionDBConnection.instance.execute(<<-SQL, question_id)
    SELECT
      COUNT(*)
    FROM
        question_likes
    JOIN questions
      ON question_likes.question_id = questions.id
      WHERE question_id = ?
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
        question_likes (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionDBConnection.instance.execute(<<-SQL, @id, @user_id, @question_id)
      UPDATE
        question_likes
      SET
        user_id = ?, question_id = ?
      WHERE
        id = ?
    SQL
  end
end
