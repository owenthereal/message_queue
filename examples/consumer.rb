require_relative "../lib/message_queue"

MessageQueue.with_connection(:adapter => :bunny, :serializer => :message_pack) do |conn|
  consumer = conn.new_consumer(
    :queue => {
      :name => "print_time_now"
    },
    :exchange => {
      :name => "time",
      :routing_key => "time.#"
    },
    :subscribe => {
      :block => true
    }
  )

  consumer.subscribe do |delivery_info, metadata, payload|
    puts "Received message: #{payload}"
  end
end
