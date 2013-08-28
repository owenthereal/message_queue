require_relative "test_helper"

class MessageQueueTest < Test::Unit::TestCase
  def test_load_adapter
    adapter = MessageQueue.load_adapter(:bunny)
    assert_equal "MessageQueue::Adapters::Bunny", adapter.name

    adapter = MessageQueue.load_adapter(:foo)
    assert_nil adapter
  end

  def test_new_connection
    assert_raises RuntimeError do
      MessageQueue.new_connection(:adapter => :foo)
    end

    connection = MessageQueue.new_connection(:adapter => :bunny,
                                             :uri => "amqp://user:pass@host/vhost")
    assert_equal "MessageQueue::Adapters::Bunny::Connection", connection.class.to_s
  end
end
