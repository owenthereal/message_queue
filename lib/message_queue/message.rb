module MessageQueue
  class Message
    attr_reader :message_id, :type, :payload, :timestamp

    def initialize(options = {})
      @message_id = options.fetch(:message_id)
      @type = options.fetch(:type)
      @payload = options.fetch(:payload)
      @timestamp = options.fetch(:timestamp)
    end
  end
end
