module Calculus
  module ManureManagementPlan

    class AbstractQuestionPrefiller

      def self.prefill(question_group)
        #implement this method to define the values you desire
        raise NotImplemented
      end

      def self.prefill_questions(question_group)
        answer_to_questions(self.prefill(question_group))
      end

    end
  end
end