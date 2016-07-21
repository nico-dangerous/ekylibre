module Calculus
  module ManureManagementPlan

    class Question

      def initialize(args)
        @name = args["name"]
        #use to translate the question label
        @translation_key = args["translation_key"]
        @default_answer = args["default_value"]
        #type of data expected
        @type = args["type"]
        @answer = nil
      end

      def text
        #return translated text
        raise TODO
      end

      def answered?
        return @answer.nil?
      end

    end
  end
end