require "observer"

class MessageQueue::Adapters::Memory::Connection::Publisher < MessageQueue::Publisher
  include Observable

  def publish(object, options = {})
    changed
    notify_observers(dump_object(object), default_options.merge(options))
  end
end
