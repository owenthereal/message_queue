class MessageQueue::Adapters::Bunny::Connection
  attr_reader :serializer, :settings, :connection

  # Public: Initialize a new Bunny connection.
  #
  # serializer - The Serializer for dumping and loading payload.
  #
  # settings   - The Hash settings used to connect with Bunny.
  #              Details in http://rubybunny.info/articles/connecting.html.
  #
  # Returns a Connection wrapper for Bunny.
  def initialize(serializer, settings)
    @serializer = serializer
    @settings = settings
  end

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

  # Public: Connect to RabbitMQ, execute the block and disconnect
  #
  # Returns nothing
  def with_connection(&block)
    begin
      connect
      block.call(self)
    ensure
      disconnect
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
