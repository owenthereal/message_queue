require "multi_json"

module MessageQueue
  module Serializers
    class Json < Serializer
      def load(string, options = {})
        ::MultiJson.load(string, options)
      end

      def dump(object, options = {})
        ::MultiJson.dump(object, options)
      end

      def content_type
        "application/json"
      end
    end
  end
end
