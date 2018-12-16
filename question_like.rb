require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'user'
require_relative 'reply'
require_relative 'model_base'

class QuestionLike
    attr_accessor :question_id, :user_id
    attr_reader :id

    def self.find_by_id(id)
        result = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_likes
            WHERE
                id = ?
        SQL

        return nil unless result.length > 0
        QuestionLike.new(result.first)
    end

    def self.likers_for_question_id(question_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, question_id: question_id)
        SELECT
            users.*
        FROM
            users
        JOIN
            question_likes ON question_likes.user_id = users.id
        WHERE
            question_likes.question_id = :question_id
        SQL

        return nil unless results.length > 0
        results.map { |result| User.new(result) }
    end

    def self.num_likes_for_question_id(question_id)
        result = QuestionsDBConnection.instance.execute(<<-SQL, question_id: question_id)
        SELECT
            COUNT(*) as likes
        FROM
            users
        JOIN
            question_likes ON question_likes.user_id = users.id
        WHERE
            question_likes.question_id = :question_id
        SQL

        result.first
    end

    def self.liked_questions_for_user_id(user_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, user_id: user_id)
        SELECT
            questions.*
        FROM
            questions
        JOIN
            question_likes ON question_likes.question_id = questions.id
        WHERE
            question_likes.user_id = :user_id
        SQL
        return nil unless results.length > 0
        results.map { |result| Question.new(result) }
    end

    def self.most_liked_questions(n)
        results = QuestionsDBConnection.instance.execute(<<-SQL, limit: n)
        SELECT
            questions.*
        FROM
            questions
        JOIN
            question_likes ON question_likes.question_id = questions.id
        JOIN
            users ON questions_likes.user_id = users.id
        GROUP BY
            question_likes.question_id
        LIMIT
            :limit
        SQL
        return nil unless results.length > 0
        results.map { |result| Question.new(result) }
    end

    def initialize(option)
        @id = option['id']
        @question_id = option['question_id']
        @user_id = option['user_id']        
    end
    
end