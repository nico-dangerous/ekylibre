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
      
      def animal_output
        raise NotImplemented
      end
      
      def soil_supplies
        raise NotImplemented
      end
      
      def estimate_irrigation_water_nitrogen
        raise NotImplemented
      end
      
      def estimate_organic_fertilizer_mineral_fraction
        raise NotImplemented
      end
      
    end
  end
end
