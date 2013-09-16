require "securerandom"

module MessageQueue
  class Producer
    attr_reader :connection, :options

    def initialize(connection, options = {})
      @connection = connection
      @options = options.dup
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
