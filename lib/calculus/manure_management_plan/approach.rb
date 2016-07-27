module Calculus
  module ManureManagementPlan
    class Approach < AbstractApproach
    # An Approach must be linked with a model to delegate all data request
    # The model may not be any class providing the delegated method (not necessarily an ActiveRecord::Base)
    # Thus Approach does not depend of any database architecture
      delegate :name, :actions, :needs_nature, to: :@model

      def initialize(model)
        @model = model
        @question_group = QuestionGroup.new(model.questions)
      end

      def method_missing(method, *args, &block)
        #in case of method_missing, it is caught has a question
        return res if res = @question_group.ask(method)
        super
      end

    end
  end
end