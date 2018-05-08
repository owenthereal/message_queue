require_relative "test_helper"

class ConsumableTest < Test::Unit::TestCase
  class Consumer
    attr_reader :message

    include MessageQueue::Consumable
  end

  def setup
    start_test_logger

    MessageQueue.connect(:adapter => :bunny, :serializer => :plain)
  end

  def teardown
    MessageQueue.disconnect

    stop_test_logger
  end

  def build_producer
    MessageQueue.new_producer(
      :exchange => {
        :name => "test_consumable",
        :type => :direct,
        :auto_delete => true
      },
      :message => {
        :routing_key => "test_consumable"
      }
    )
  end

  def configure_valid_consumer
    Consumer.queue :name => "test_consumable", :auto_delete => true
    Consumer.exchange :name => "test_consumable"
    Consumer.send(:define_method, :process) do |message|
      @message = message
    end
  end

  def configure_invalid_consumer
    Consumer.queue :name => "test_consumable", :auto_delete => true
    Consumer.exchange :name => "test_consumable"
    Consumer.send(:define_method, :process) do |message|
      raise 'failed processing message!'
    end
  end

  def build_consumer
    consumer = Consumer.new
    consumer.subscribe
    consumer
  end

  def test_consumable
    configure_valid_consumer
    producer = build_producer
    consumer = build_consumer

    msg = Time.now.to_s

    producer.publish msg

    sleep 1

    assert_equal msg, consumer.message.payload

    assert @test_logger.buffer.include?(msg)
  end

  def test_consumable_logs_errors
    configure_invalid_consumer
    producer = build_producer
    consumer = build_consumer

    msg = Time.now.to_s

    producer.publish msg

    sleep 1

    assert @test_logger.buffer.include?(msg)
    assert @test_logger.buffer.include?('failed processing message!')
  end

  def test_consumable_custom_error_handler
    test_handler = TestMessageHandler.new
    MessageQueue.register_error_handler :message, test_handler

    configure_invalid_consumer
    producer = build_producer
    consumer = build_consumer

    msg = Time.now.to_s

    producer.publish msg

    sleep 1

    assert test_handler.buffer.include?('failed processing message!')
  end

  def test_consumable_does_not_use_unrelated_handler_types
    test_handler = TestMessageHandler.new
    MessageQueue.register_error_handler :connection, test_handler

    configure_invalid_consumer
    producer = build_producer
    consumer = build_consumer

    msg = Time.now.to_s

    producer.publish msg

    sleep 1

    assert test_handler.buffer.empty?
  end
end
