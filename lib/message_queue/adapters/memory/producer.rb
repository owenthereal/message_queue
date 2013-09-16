require "observer"

class MessageQueue::Adapters::Memory::Connection::Producer < MessageQueue::Producer
  include Observable

  def publish(object, options = {})
    changed
    notify_observers(dump_object(object), default_options.merge(options))
    true
  end
end
