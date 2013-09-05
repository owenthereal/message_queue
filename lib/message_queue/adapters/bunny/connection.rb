class MessageQueue::Adapters::Bunny::Connection < MessageQueue::Connection
  attr_reader :connection

  # Public: Connect to RabbitMQ
  #
  # Returns the Bunny instance
  def connect
    @connection ||= begin
                      bunny = ::Bunny.new(settings)
                      bunny.start
                      bunny
                    end
  end

  # Public: Disconnect from RabbitMQ
  #
  # Returns nothing
  def disconnect
    if @connection
      @connection.close if @connection.open?
      @connection = nil
    end
  end

  def new_publisher(options)
    raise "No connection to RabbitMQ" unless connection

    Publisher.new(self, options)
  end

  def new_consumer(options)
    raise "No connection to RabbitMQ" unless connection

    Consumer.new(self, options)
  end
end

require "message_queue/adapters/bunny/publisher"
require "message_queue/adapters/bunny/consumer"
