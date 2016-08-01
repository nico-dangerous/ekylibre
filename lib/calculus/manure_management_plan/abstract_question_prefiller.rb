module Calculus
  module ManureManagementPlan

    class AbstractQuestionPrefiller

      def self.prefill(question_group)
        #Return a hash with {question_label => answer, ...}
        raise NotImplemented
      end

      def self.prefill_questions(question_group)
        question_group.answer_to_questions(self.prefill(question_group))
      end

    end
  end
end