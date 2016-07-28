module Calculus
  module ManureManagementPlan

    class QuestionGroup

      def initialize(questions)
        #questions must be a hash of question  :  label = {text, answer, type}
        @questions = questions
      end

      def ask(question_label)
        #Return the actual answer for the question
        @questions[label].answer if @questions[label]
      end

      def answers
        answers = {}
        @questions.each do |question|
          answers[question["label"]]=question["answer"]
        end
        answers
      end

      def questions
        return @questions
      end

      def answer_to_questions(answers)
        @questions.each do |question|
          if answers.keys.include?(question["label"])
            question["answer"] = answers[question["label"].to_s].to_s
          end
        end
      end

      def labels
        labels = []
        questions.map {|question| labels << question["label"]}
        labels
      end

    end
  end
end