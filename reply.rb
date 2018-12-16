require_relative 'questions_database'
require_relative 'question'
require_relative 'user'
require_relative 'model_base'

class Reply < ModelBase
    attr_accessor :question_id, :body, :author_id, :parent_reply_id
    attr_reader :id

    def self.find_by_id(id)
        result = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                replies
            WHERE
                id = ?
        SQL

        return nil unless result.length > 0
        Reply.new(result.first)
    end

    def self.find_by_user_id(user_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, user_id: user_id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.author_id = :user_id
        SQL
        return nil unless results.length > 0
        results.map { |result| Reply.new(result) }
    end

    def self.find_by_question_id(question_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, question_id: question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.question_id = :question_id
        SQL
        return nil unless results.length > 0
        results.map { |result| Reply.new(result) }
    end

    def initialize(option)
        @id = option['id']
        @question_id = option['question_id']
        @body = option['body']
        @authod_id = option['author_id']
        @parent_reply_id = option['parent_reply_id']
    end

    def author
        User.find_by_id(self.author_id)
    end

    def question
        Question.find_by_id(self.question_id)
    end

    def parent_reply
        Reply.find_by_id(self.parent_reply_id)
    end

    def child_replies
        results = QuestionsDBConnection.instance.execute(<<-SQL, parent_reply_id: self.id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.parent_reply_id = :parent_reply_id
        SQL
        return nil unless results.length > 0
        results.map { |result| Reply.new(result) }
    end

    def save
        if self.id
            QuestionsDBConnection.instance.execute(<<-SQL, question_id: question_id, parent_reply_id: parent_reply_id, body: body, author_id: author_id, id: self.id)
            UPDATE
                replies
            SET
                question_id = :question_id, parent_reply_id = :parent_reply_id, body = :body, author_id = :author_id
            WHERE
                id = :id
            SQL
        else
            QuestionsDBConnection.instance.execute(<<-SQL, question_id: question_id, parent_reply_id: parent_reply_id, body: body, author_id: author_id)
            INSERT INTO
                replies(question_id, parent_reply_id, body, author_id)
            VALUES
                (:question_id, :parent_reply_id, :body, :author_id)
            SQL

            self.id = QuestionsDBConnection.last_insert_row_id
        end

        self
    end 
    
end