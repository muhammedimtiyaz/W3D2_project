require_relative 'questions_database'

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

    def initialize(option)
        @id = option['id']
        @question_id = option['question_id']
        @user_id = option['user_id']        
    end
    
end