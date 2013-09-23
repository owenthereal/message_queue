require "message_queue/options_helper"

module MessageQueue
  class Consumer
    include OptionsHelper

    attr_reader :connection, :options

    def initialize(connection, options = {})
      @connection = connection
      @options = deep_clone(options)
    end

    def load_object(object)
      connection.serializer.load(object)
    end
  end
end
