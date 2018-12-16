require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'user'
require_relative 'reply'
require_relative 'model_base'

class User
    attr_accessor :fname, :lname
    attr_reader :id

    def self.find_by_id(id)
        result = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                users
            WHERE
                id = ?
        SQL

        return nil unless result.length > 0
        User.new(result.first)
    end

    def self.find_by_name(fname, lname)
        result = QuestionsDBConnection.instance.execute(<<-SQL, fname: fname, lname: lname)
            SELECT
                *
            FROM
                users
            WHERE
                users.fname = :fname AND users.lname = :lname
        SQL
        return nil unless result.length > 0
        User.new(result.first)
    end

    def initialize(option)
        @id = option['id']
        @fname = option['fname']
        @lname = option['lname']
    end

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end

    def followed_questions
        QuestionFollow.followed_question_for_user_id(self.id)
    end

    def liked_questions
        QuestionLike.liked_questions_for_user_id(id)
    end

    def average_karma
        result = QuestionsDBConnection.instance.execute(<<-SQL, author_id: self.id)
        SELECT CAST(COUNT(question_likes.id) AS FLOAT) / COUNT(DISTINCT(questions.id)) AS avg_karma
        FROM questions
        LEFT JOIN question_likes ON questions.id = question_likes.question_id
        WHERE questions.author_id = :author_id
        SQL
    end

    def save
        if self.id
            QuestionsDBConnection.instance.execute(<<-SQL, fname: fname, lname: lname, id: self.id)
            UPDATE
                users
            SET
                fname = :fname, lname = :lname
            WHERE
                id = :id
            SQL
        else
            QuestionsDBConnection.instance.execute(<<-SQL, fname: fname, lname: lname)
            INSERT INTO
                users(fname, lname)
            VALUES
                (:fname, :lname)
            SQL

            self.id = QuestionsDBConnection.last_insert_row_id
        end

        self
    end


end