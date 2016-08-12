module Calculus
  module ManureManagementPlan
    class QuestionGroup
      def initialize(questions)
        # questions must be a hash of question  :  label = {text, answer, type}
        @questions = questions
      end

      def ask(question_label)
        # Return the actual answer for the question
        @questions[question_label.to_s]['answer'] if @questions[question_label.to_s]
      end

      def answers
        answers = {}
        @questions.each do |question|
          if answers[question['label']]
            answers[question['label']] = question['answer']
          end
        end
        answers
      end

      attr_reader :questions

      def answer_to_questions(answers)
        @questions.each do |question|
          if answers.keys.include?(question['label'])
            question['answer'] = answers[question['label'].to_s].to_s
          end
        end
      end

      def labels
        labels = []
        @questions.map { |question| labels << question['label'] }
        labels
      end

      def has_answers?
        answers.empty?
      end
    end
  end
end
