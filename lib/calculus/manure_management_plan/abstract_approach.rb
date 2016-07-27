module Calculus
  module ManureManagementPlan
    class AbstractApproach


        def yields_procedure_questions
          # return a hash,
          #  { var1 => type1, ... varn => typen}
          # with [var1 ... varn] = parameters name
          #      |type1 ... typen] are data type (int, string ...)
          raise NotImplemented
        end

        def yields_procedure(args)
          # return a hash with the following keys :
          # yield forecast:
          # the args used for computation
          raise NotImplemented
        end

        def needs_procedure_questions
          # return a hash, keys are the parameters name, values are types
          raise NotImplemented
        end

        def needs_procedure(args)
          # return a hash with the following keys :
          # needs:
          # the args used for computation
          raise NotImplemented
        end
    end
  end
end
