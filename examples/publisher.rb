require_relative "../lib/message_queue"

MessageQueue.with_connection(:adapter => :bunny, :serializer => :message_pack) do |conn|
  publisher = conn.new_publisher(
    :exchange => {
      :name => "time",
      :type => :topic
    },
    :message => {
      :routing_key => "time.now"
    }
  )

  publisher.publish Time.now.to_s
end
