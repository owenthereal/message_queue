# encoding: utf-8
require_relative "test_helper"

class ConsumableTest < Test::Unit::TestCase
  class Consumer
    attr_reader :message

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
        :type => :direct,
        :auto_delete => true
      },
      :message => {
        :routing_key => "test_consumable"
      }
    )

    Consumer.queue :name => "test_consumable", :auto_delete => true
    Consumer.exchange :name => "test_consumable"
    Consumer.send(:define_method, :process) do |message|
      @message = message
    end
    consumer = Consumer.new
    consumer.subscribe

    msg = Time.now.to_s + '™'
    producer.publish msg

    sleep 1

    assert_equal msg, consumer.message.payload
    assert_equal "UTF-8", "#{consumer.message.payload.encoding}".upcase
  end
end
