require "singleton"

module MessageQueue
  module Serializers
    class Serializer
      include Singleton

      class << self
        def load(string, options = {})
          instance.load(string, options)
        end

        def dump(object, options = {})
          instance.dump(object, options)
        end

        def content_type
          instance.content_type
        end
      end
    end
  end
end
