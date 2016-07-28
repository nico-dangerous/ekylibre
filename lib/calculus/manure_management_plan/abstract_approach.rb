module Calculus
  module ManureManagementPlan
    class AbstractApproach

        def yields_procedure
          # return a hash with the following keys :
          # yield forecast:
          # the args used for computation
          raise NotImplemented
        end

        def needs_procedure
          # return a hash with the following keys :
          # needs:
          # the args used for computation
          raise NotImplemented
        end

    end
  end
end
