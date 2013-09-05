require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/plain"
require_relative "../../lib/message_queue/adapters/memory"

class MemoryTest < Test::Unit::TestCase
  def test_pub_sub
    connection = MessageQueue::Adapters::Memory.new_connection MessageQueue::Serializers::Plain
    connection.with_connection do |conn|
      publisher = conn.new_publisher
      consumer = conn.new_consumer
      consumer.subscribe(:publisher => publisher)

      msg = Time.now.to_s
      publisher.publish msg, :type => :time

      options, payload = consumer.queue.pop
      assert_equal :time, options[:type]
      assert_equal msg, payload
    end
  end
end
