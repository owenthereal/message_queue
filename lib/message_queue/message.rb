module MessageQueue
  class Message
    attr_reader :attributes, :message_id, :type, :payload, :timestamp, :routing_key

    def initialize(attributes = {})
      @attributes = attributes
      @message_id = attributes[:message_id]
      @type = attributes[:type]
      @payload = attributes[:payload]
      @timestamp = attributes[:timestamp]
      @routing_key = attributes[:routing_key]
    end
  end
end
