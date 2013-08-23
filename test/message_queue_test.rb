require_relative "test_helper"

class MessageQueueTest < Test::Unit::TestCase
  def test_load_adapter
    adapter = MessageQueue.load_adapter(:bunny)
    assert_equal "MessageQueue::Adapters::Bunny", adapter.name

    adapter = MessageQueue.load_adapter(:foo)
    assert_nil adapter
  end

  def test_setup
    MessageQueue.setup(:adapter => :bunny,
                       :url => "amqp://user:pass@host/vhost")
    assert_equal :bunny, MessageQueue.config.adapter
  end
end
