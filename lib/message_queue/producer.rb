require "securerandom"
require "message_queue/options_helper"

module MessageQueue
  class Producer
    include OptionsHelper

    attr_reader :connection, :options

    def initialize(connection, options = {})
      @connection = connection
      @options = deep_clone(options)
    end

    def dump_object(object)
      connection.serializer.dump(object)
    end

    def default_options
      { :content_type => connection.serializer.content_type, :timestamp => Time.now.utc.to_i, :message_id => generate_id }
    end

    private

    def generate_id
      SecureRandom.uuid
    end
  end
end
