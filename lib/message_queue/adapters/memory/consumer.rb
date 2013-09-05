class MessageQueue::Adapters::Memory::Connection::Consumer < MessageQueue::Consumer
  attr_reader :queue, :block

  def initialize(*args)
    super
    @queue = []
  end

  def subscribe(options = {}, &block)
    publisher = options.fetch(:publisher)
    publisher.add_observer(self)
    @block = block
  end

  def unsubscribe(options = {})
    publisher = options.fetch(:publisher)
    publisher.delete_observer(self)
    @block = nil
  end

  def update(object, options)
    options, object = options, load_object(object)
    if block
      block.call(options, object)
    else
      queue << [options, object]
    end
  end
end
