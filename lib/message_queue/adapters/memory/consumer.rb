class MessageQueue::Adapters::Memory::Connection::Consumer < MessageQueue::Consumer
  attr_reader :queue, :block

  def initialize(*args)
    super
    @queue = []
  end

  def subscribe(options = {}, &block)
    producer = options.fetch(:producer)
    producer.add_observer(self)
    @block = block
  end

  def unsubscribe(options = {})
    producer = options.fetch(:producer)
    producer.delete_observer(self)
    @block = nil
  end

  def update(object, options)
    options, object = options, load_object(object)
    message = MessageQueue::Message.new(:message_id => options[:message_id],
                                        :type => options[:type],
                                        :timestamp => options[:timestamp],
                                        :payload => load_object(object))
    if block
      block.call(message)
    else
      queue << message
    end
  end
end
