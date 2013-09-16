class MessageQueue::Adapters::Memory::Connection < MessageQueue::Connection
  def new_producer(options = {})
    Producer.new(self, options)
  end

  def new_consumer(options = {})
    Consumer.new(self, options)
  end
end

require "message_queue/adapters/memory/producer"
require "message_queue/adapters/memory/consumer"
