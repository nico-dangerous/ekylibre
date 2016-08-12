module Calculus
  module ManureManagementPlan
    class AbstractApproach
      def estimate_expected_yield
        raise NotImplemented
      end

      def estimated_needs
        raise NotImplemented
      end

      def estimated_supply
        raise NotImplemented
      end

      def estimated_input
        raise NotImplemented
      end
    end
  end
end
