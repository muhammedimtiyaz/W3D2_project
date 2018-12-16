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

    def followed_question
        QuestionFollow.followed_question_for_user_id(self.id)
    end


end