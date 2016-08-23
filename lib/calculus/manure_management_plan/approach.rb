module Calculus
  module ManureManagementPlan
    class Approach < AbstractApproach
      # An approach has to answer to a question_group, by filling the question_group.answer hash

      delegate :name, :actions, :supply_nature, :parameters, :manure_management_plan_zone, :questions, to: :@application

      def initialize(application)
        @application = application
        @question_group = QuestionGroup.new(questions)
      end

      def self.build_approach(application)
        Object.const_get(application.approach.classname).new(application)
      end

      def questions_answered?
        @question_group.has_answers?
      end

      def budget_estimate_expected_yield
        manure_management_plan_zone.activity_production.estimate_yield
      end

      def self.humanize_result(key_result)
        I18n.translate("MMP.approach.result.#{key_result}")
      end

      def self.humanize_question(key_question)
        I18n.translate("MMP.approach.question.#{key_question}")
      end
    end
  end
end
