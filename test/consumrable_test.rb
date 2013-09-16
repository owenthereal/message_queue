require_relative "test_helper"

class ConsumableTest < Test::Unit::TestCase
  class Consumer
    include MessageQueue::Consumable
  end

  def setup
    MessageQueue.connect(:adapter => :bunny, :serializer => :plain)
  end

  def teardown
    MessageQueue.disconnect
  end

  def test_consumable
    producer = MessageQueue.new_producer(
      :exchange => {
        :name => "test_consumable",
        :type => :direct
      },
      :message => {
        :routing_key => "test_consumable"
      }
    )

    msg = Time.now.to_s

    Consumer.queue :name => "test_consumable"
    Consumer.exchange :name => "test_consumable"
    Consumer.send(:define_method, :process) do |drgselivery_info, metadata, payload|
      assert_equal msg, payload
    end
    consumer = Consumer.new
    consumer.subscribe

    producer.publish msg
  end
end
