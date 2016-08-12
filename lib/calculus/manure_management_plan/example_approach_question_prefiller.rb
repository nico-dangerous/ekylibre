module Calculus
  module ManureManagementPlan
    class ExampleApproachQuestionPrefiller < AbstractQuestionPrefiller
      def self.prefill(_question_group)
        answers = {}
        answers['foo'] = 'foofoo'
        answers['bar'] = 'barbar'
        answers
      end
    end
  end
end
