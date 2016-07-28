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



    end
  end
end