class MessageQueue::Adapters::Memory::Connection < MessageQueue::Connection
  def new_publisher(options = {})
    Publisher.new(self, options)
  end

  def new_consumer(options = {})
    Consumer.new(self, options)
  end
end

require "message_queue/adapters/memory/publisher"
require "message_queue/adapters/memory/consumer"
