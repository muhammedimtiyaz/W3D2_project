require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'user'
require_relative 'reply'
require_relative 'model_base'

class QuestionFollow
    attr_accessor :question_id, :user_id
    attr_reader :id

    def self.find_by_id(id)
        result = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                question_follows
            WHERE
                id = ?
        SQL

        return nil unless result.length > 0
        QuestionFollow.new(result.first)
    end

    def self.followers_for_question_id(question_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, question_id: question_id)
            SELECT
                users.*
            FROM
                users
            JOIN
                question_follows ON question_follows.user_id = users.id
            WHERE
                question_follows.question_id = :question_id
        SQL

        return nil unless results.length > 0
        results.map { |result| User.new(result) }   
    end

    def self.followed_questions_for_user_id(user_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, user_id: user_id)
            SELECT
                questions.*
            FROM
                questions
            JOIN
                question_followss ON questions.id = question_follows.question_id
            WHERE
                question_follows.users_id = :user_id
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