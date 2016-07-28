module Calculus
  module ManureManagementPlan

    class ExampleApproach < Approach

      def yields_procedure

        #Retrieve data
        ExampleApproachQuestionPrefiller.prefill_questions(@question_group)
        result = {toto: 10, tata: 30 }
        byebug
      end

      def needs_procedure
        # return a hash with the following keys :
        # needs:
        # the args used for computation
        EmptyQuestionPrefiller.prefill_questions(@question_group)

        result = {kayak: 1.0, kayak: 0.1 }
      end

    end

  end
end