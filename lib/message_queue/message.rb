module MessageQueue
  class Message
    attr_reader :attributes, :message_id, :type, :payload, :timestamp

    def initialize(attributes = {})
      @attributes = attributes
      @message_id = attributes.fetch(:message_id)
      @type = attributes.fetch(:type)
      @payload = attributes.fetch(:payload)
      @timestamp = attributes.fetch(:timestamp)
    end
  end
end
