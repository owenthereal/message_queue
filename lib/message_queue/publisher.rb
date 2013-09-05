require "securerandom"

module MessageQueue
  class Publisher
    attr_reader :connection, :options

    def initialize(connection, options = {})
      @connection = connection
      @options = options.dup
    end

    def dump_object(object)
      connection.serializer.dump(object)
    end

    def default_options
      { :content_type => connection.serializer.content_type, :timestamp => Time.now.utc.to_i, :message_id => SecureRandom.uuid }
    end
  end
end
