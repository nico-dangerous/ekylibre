module Calculus
  module ManureManagementPlan
    class ExampleApproach < Approach
      def initialize(application)
        super(application)
      end

      def yields_procedure
        # Retrieve data

        result = { toto: 10, tata: 30 }
      end

      def needs_procedure
        # return a hash with the following keys :
        # needs:
        # the args used for computation

        result = { kayak: 1.0, kayak: 0.1 }
      end
    end
  end
end
