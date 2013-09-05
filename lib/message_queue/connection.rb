class MessageQueue::Connection
  attr_reader :serializer, :settings

  # Public: Initialize a new Bunny connection.
  #
  # serializer - The Serializer for dumping and loading payload.
  #
  # settings   - The Hash settings used to connect.
  #
  #
  # Returns a Connection wrapper for Bunny.
  def initialize(serializer, settings)
    @serializer = serializer
    @settings = settings
  end

  # Public: Connect to the message queue
  #
  # Returns nothing
  def connect
  end

  # Public: Disconnect from the message queue
  #
  # Returns nothing
  def disconnect
  end

  # Public: Connect to the message, execute the block and disconnect
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

  def new_publisher(options = {})
    Publisher.new(self, options)
  end

  def new_consumer(options = {})
    Consumer.new(self, options)
  end
end

require "message_queue/publisher"
require "message_queue/consumer"