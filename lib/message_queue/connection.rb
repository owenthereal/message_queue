require "message_queue/logging"

class MessageQueue::Connection
  include MessageQueue::Logging

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
    logger.info("connecting with adapter #{self.class} and settings #{settings}")
  end

  # Public: Disconnect from the message queue
  #
  # Returns nothing
  def disconnect
    logger.info("disconnecting")
  end

  # Public: Check if it's connected to the message queue
  #
  # Returns true if it's connected
  def connected?
    false
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

  def new_producer(options = {})
    Producer.new(self, options)
  end

  def new_consumer(options = {})
    Consumer.new(self, options)
  end
end

require "message_queue/producer"
require "message_queue/consumer"
