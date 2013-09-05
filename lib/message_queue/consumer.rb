class MessageQueue::Consumer
  attr_reader :connection, :options

  def initialize(connection, options = {})
    @connection = connection
    @options = options.dup
  end

  def load_object(object)
    connection.serializer.load(object)
  end
end
