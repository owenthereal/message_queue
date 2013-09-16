class MessageQueue::Consumer
  attr_reader :connection, :options

  def initialize(connection, options = {})
    @connection = connection
    @options = Marshal.load(Marshal.dump(options)) # deep cloning options
  end

  def load_object(object)
    connection.serializer.load(object)
  end
end
