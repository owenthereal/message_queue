require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/plain"
require_relative "../../lib/message_queue/adapters/bunny"

class ErrorBunny < MessageQueue::Adapters::Bunny
  class ErrorBunnyConnection < MessageQueue::Adapters::Bunny::Connection
    class << self
      attr_accessor :bunny_adapter_class
    end
  end

  class ErrorBunnyAdapter
    def initialize(*)
    end

    def start
      raise 'Connection error!'
    end
  end

  def new_connection(serializer, settings)
    ErrorBunnyConnection.new(serializer, settings)
  end
end

class BunnyTest < Test::Unit::TestCase
  def setup
    @original_logger = MessageQueue::Logging.logger
    @test_logger = TestLogger.new
    MessageQueue::Logging.logger = @test_logger

    ErrorBunny::ErrorBunnyConnection.bunny_adapter_class = ErrorBunny::ErrorBunnyAdapter
  end

  def teardown
    MessageQueue::Logging.logger = @original_logger
  end

  def producer_config
    {
      :exchange => {
        :name => "test_exchange",
        :type => :direct,
        :auto_delete => true
      },
      :message => {
        :routing_key => "test_queue"
      }
    }
  end

  def consumer_config
    {
      :exchange => {
        :name => "test_exchange"
      },
      :queue => {
        :name => "test_queue",
        :auto_delete => true
      }
    }
  end

  def test_new_connection
    connection = MessageQueue::Adapters::Bunny.new_connection(
      MessageQueue::Serializers::Plain,
      :uri => "amqp://user:pass@host/vhost",
      :tls_certificates => ["path"])
    assert_equal "amqp", connection.settings[:scheme]
    assert_equal ["path"], connection.settings[:tls_certificates]

    connection = MessageQueue::Adapters::Bunny.new_connection MessageQueue::Serializers::Plain
    connection.connect
    assert connection.connected?

    connection.disconnect
    assert !connection.connected?
  end

  def test_new_producer
    connection = MessageQueue::Adapters::Bunny.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      producer = conn.new_producer(producer_config)

      assert_equal "test_exchange", producer.exchange_name
      assert_equal :direct, producer.exchange_type
      assert_equal "test_queue",  producer.message_options[:routing_key]

      ch = connection.connection.create_channel
      queue = ch.queue("test_producer", :auto_delete => true).bind("test_exchange", :routing_key => "test_queue")

      @payload = nil
      queue.subscribe do |_, _, payload|
        @payload = payload
      end

      msg = Time.now.to_s
      producer.publish msg

      sleep 1

      assert_equal msg, @payload
    end
  end

  def test_new_consumer
    connection = MessageQueue::Adapters::Bunny.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      producer = conn.new_producer(producer_config)
      consumer = conn.new_consumer(consumer_config)

      assert_equal "test_queue", consumer.queue_name
      assert_equal "test_exchange", consumer.exchange_name

      @payload = nil
      consumer.subscribe do |message|
        @payload = message.payload
      end

      msg = Time.now.to_s
      producer.publish msg, :type => :foo

      sleep 1

      assert_equal msg, @payload
    end
  end

  def test_connection_error
    connection = ErrorBunny.new_connection MessageQueue::Serializers::Plain
    connection.connect

    assert @test_logger.buffer.include?('Connection error!')
  end

  def test_verify_connection
    msg = Time.now.to_s
    error_string = 'Connection error!'

    connection = ErrorBunny.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      producer = conn.new_producer(producer_config)
      refute producer.publish(msg)
      assert @test_logger.buffer.include?(error_string)

      ErrorBunny::ErrorBunnyConnection.bunny_adapter_class = ::Bunny
      @test_logger.buffer.clear

      producer = conn.new_producer(producer_config)
      assert producer.publish(msg)
      refute @test_logger.buffer.include?(error_string)
    end
  end
end
