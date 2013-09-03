require "singleton"

module MessageQueue
  module Adapters
    class Adapter
      include Singleton

      class << self
        def new_connection(serializer, options = {})
          instance.new_connection(serializer, options)
        end
      end
    end
  end
end
