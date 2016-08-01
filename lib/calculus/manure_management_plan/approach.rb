module Calculus
  module ManureManagementPlan
    class Approach < AbstractApproach
      #An approach has to answer to a question_group, by filling the question_group.answer hash

      delegate :name, :actions, :supply_nature, to: :@model

      def initialize(model)
        @model = model
        @question_group = QuestionGroup.new(model.questions["questions"].values)
      end

      def self.build_approach(model)
        Object.const_get("Calculus::ManureManagementPlan::"+model.name).new(model)
      end

      def questions
        return @question_group.questions.dup
      end

      def questions_answered?
        @question_group.has_answers?
      end

    end
  end
end