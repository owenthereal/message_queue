module MessageQueue
  module Serializers
    class Plain < Serializer
      def load(string, options = {})
        string
      end

      def dump(object, options = {})
        object
      end
    end
  end
end
