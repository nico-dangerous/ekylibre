module Calculus
  module ManureManagementPlan
    class EmptyQuestionPrefiller < AbstractQuestionPrefiller
      # Question prefiller setting all answer to an  empty_string

      def self.prefill(question_group)
        answers = {}
        question_group.labels.each do |key|
          answers[key] = ''
        end
        answers
      end
    end
  end
end
