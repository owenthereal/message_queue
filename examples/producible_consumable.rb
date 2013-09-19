require_relative "../lib/message_queue"

class Producer
  include MessageQueue::Producible

  exchange :name => "time", :type => :topic
  message :routing_key => "time.now", :mandatory => true
end

class Consumer
  include MessageQueue::Consumable

  queue :name => "print_time_now"
  exchange :name => "time", :routing_key => "time.#"

  def process(message)
    puts "Received message #{message.payload}"
  end
end

MessageQueue.connect(:adapter => :bunny, :serializer => :json)
MessageQueue.run_consumables

Producer.new.publish(Time.now.to_s)

sleep 1

MessageQueue.disconnect
