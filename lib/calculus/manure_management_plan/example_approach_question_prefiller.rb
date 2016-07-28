module Calculus
  module ManureManagementPlan

    class ExampleApproachQuestionPrefiller < AbstractQuestionPrefiller

      def self.prefill(question_group)
        answers = {}
        answers["foo"] = "foofoo"
        answers["bar"] = "barbar"
        return answers
      end

    end
  end
end