require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/plain"
require_relative "../../lib/message_queue/adapters/bunny"

class BunnyTest < Test::Unit::TestCase
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
      producer = conn.new_producer(
        :exchange => {
          :name => "test_producer",
          :type => :direct,
          :auto_delete => true
        },
        :message => {
          :routing_key => "test_producer"
        }
      )

      assert_equal "test_producer", producer.exchange_name
      assert_equal :direct, producer.exchange_type
      assert_equal "test_producer",  producer.message_options[:routing_key]

      ch = connection.connection.create_channel
      queue = ch.queue("test_producer", :auto_delete => true).bind("test_producer", :routing_key => "test_producer")

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
      producer = conn.new_producer(
        :exchange => {
          :name => "test_consumer",
          :type => :direct,
          :auto_delete => true
        },
        :message => {
          :routing_key => "test_consumer"
        }
      )

      consumer = conn.new_consumer(
        :queue => {
          :name => "test_consumer",
          :auto_delete => true
        },
        :exchange => {
          :name => "test_consumer"
        }
      )

      assert_equal "test_consumer", consumer.queue_name
      assert_equal "test_consumer", consumer.exchange_name

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
end
