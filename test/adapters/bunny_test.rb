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

  def test_new_publisher
    connection = MessageQueue::Adapters::Bunny.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      publisher = conn.new_publisher(
        :exchange => {
          :name => "test",
          :type => :direct
        },
        :message => {
          :routing_key => "test"
        }
      )

      assert_equal "test", publisher.exchange_name
      assert_equal :direct, publisher.exchange_type
      assert_equal "test",  publisher.message_options[:routing_key]

      msg = Time.now.to_s
      publisher.publish msg

      ch = connection.connection.create_channel
      queue = ch.queue("test")
      _, _, m = queue.pop

      assert_equal msg, m
    end
  end

  def test_new_consumer
    connection = MessageQueue::Adapters::Bunny.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      consumer = conn.new_consumer(
        :queue => {
          :name => "test"
        },
        :exchange => {
          :name => "test"
        }
      )

      assert_equal "test", consumer.queue_name
      assert_equal "test", consumer.exchange_name

      publisher = conn.new_publisher(
        :exchange => {
          :name => "test",
          :type => :direct
        },
        :message => {
          :routing_key => "test"
        }
      )

      msg = Time.now.to_s
      publisher.publish msg

      _, _, m = consumer.queue.pop
      assert_equal msg, m
    end
  end
end
