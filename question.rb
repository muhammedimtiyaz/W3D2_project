require_relative 'questions_database'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'user'
require_relative 'reply'
require_relative 'model_base'

class Question
    attr_accessor :title, :body, :author_id
    attr_reader :id

    def self.find_by_id(id)
        result = QuestionsDBConnection.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?
        SQL

        return nil unless result.length > 0
        Question.new(result.first)
    end

    def self.find_by_author_id(author_id)
        results = QuestionsDBConnection.instance.execute(<<-SQL, author_id: author_id)
            SELECT
                *
            FROM
                questions
            WHERE
                questions.author_id = :author_id
        SQL

        results.map { |result| Question.new(result) }
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end

    def initialize(option)
        @id  = option['id']
        @title = option['title']
        @body = option['body']
        @author_id = option['author_id']
    end

    def author
        User.find_by_id(self.author_id)
    end

    def replies
        Reply.find_by_question_id(self.question_id)
    end

    def followers
        QuestionFollow.followers_for_question_id(self.id)
    end

    def likers
        QuestionLike.likers_for_question_id(id)
    end

    def num_likes
        QuestionLike.num_likes_for_question_id(id)
    end

    def save
        if self.id
            QuestionsDBConnection.instance.execute(<<-SQL, title: title, body: body, author_id: author_id, id: self.id)
            UPDATE
                questions
            SET
                title = :title, body = :body, author_id = :author_id
            WHERE
                id = :id
            SQL
        else
            QuestionsDBConnection.instance.execute(<<-SQL, title: title, body: body, author_id: author_id)
            INSERT INTO
                questions(title, body, author_id)
            VALUES
                (:title, :body, :author_id)
            SQL

            self.id = QuestionsDBConnection.last_insert_row_id
        end

        self
    end    
end