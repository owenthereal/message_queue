require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/plain"
require_relative "../../lib/message_queue/adapters/memory"

class MemoryTest < Test::Unit::TestCase
  def test_connected?
    connection = MessageQueue::Adapters::Memory.new_connection MessageQueue::Serializers::Plain
    assert !connection.connected?
  end

  def test_pub_sub
    connection = MessageQueue::Adapters::Memory.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      producer = conn.new_producer
      consumer = conn.new_consumer
      consumer.subscribe(:producer => producer)

      msg = Time.now.to_s
      producer.publish msg, :type => :time

      message = consumer.queue.pop
      assert_equal :time, message.type
      assert_equal msg, message.payload
    end
  end
end
