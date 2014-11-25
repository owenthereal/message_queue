class MessageQueue::Adapters::Bunny::Connection < MessageQueue::Connection
  attr_reader :connection

  # Public: Connect to RabbitMQ
  #
  # Returns the Bunny instance
  def connect
    @connection ||= begin
                      super
                      bunny = self.class.bunny_adapter_class.new(bunny_settings)
                      bunny.start
                      bunny
                    end
  rescue => e
    handle_connection_error(e)
  end

  # Public: Disconnect from RabbitMQ
  #
  # Returns nothing
  def disconnect
    if @connection
      super
      @connection.close if @connection.open?
      @connection = nil
    end
  end

  # Public: Check if it's connected to the message queue
  #
  # Returns true if it's connected
  def connected?
    @connection.open? if @connection
  end

  def new_producer(options)
    raise "No connection to RabbitMQ" unless connection

    Producer.new(self, options)
  end

  def new_consumer(options)
    raise "No connection to RabbitMQ" unless connection

    Consumer.new(self, options)
  end

  private

  def bunny_settings
    default_bunny_settings.merge(settings)
  end

  def default_bunny_settings
    {
      :heartbeat => 1,
      :automatically_recover => true,
      :network_recovery_interval => 1
    }
  end

  def handle_connection_error(error)
    MessageQueue.error_handlers_for(:connection).each do |handler|
      handler.handle(error)
    end
  end

  def self.bunny_adapter_class
    ::Bunny
  end
end

require "message_queue/adapters/bunny/producer"
require "message_queue/adapters/bunny/consumer"
