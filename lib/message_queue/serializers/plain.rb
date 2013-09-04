module MessageQueue
  module Serializers
    class Plain < Serializer
      def load(string, options = {})
        string
      end

      def dump(object, options = {})
        object
      end

      def content_type
        "text/plain"
      end
    end
  end
end
