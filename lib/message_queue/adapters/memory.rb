module MessageQueue
  module Adapters
    class Memory < Adapter
      def new_connection(serializer, options = {})
        Connection.new(serializer, options)
      end
    end
  end
end

require "message_queue/adapters/memory/connection"
