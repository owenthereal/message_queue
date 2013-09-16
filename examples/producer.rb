require_relative "../lib/message_queue"

MessageQueue.with_connection(:adapter => :bunny, :serializer => :message_pack) do |conn|
  producer = conn.new_producer(
    :exchange => {
      :name => "time",
      :type => :topic
    },
    :message => {
      :routing_key => "time.now",
      :mandatory => true
    }
  )

  producer.publish Time.now.to_s
end
