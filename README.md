# MessageQueue

A common interface to multiple message queues libraries. Think of it as the
ORM to message queues.

## Installation

Add this line to your application's Gemfile:

    gem 'message_queue'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install message_queue

## Adapters

* In memory through [Observable](http://www.ruby-doc.org/stdlib-2.0.0/libdoc/observer/rdoc/Observable.html)
* RabbitMQ through [bunny](https://github.com/ruby-amqp/bunny)

## Serializers

* Plain text
* JSON through [multi_json](https://github.com/intridea/multi_json)
* Message pack through [msgpack](https://github.com/msgpack/msgpack-ruby)

## Usage

### with_connection

`with_connection` initializes a connection using the specified adapter
and serializer, connects to the message queue, runs a block of code and
disconnects.

```ruby
MessageQueue.with_connection(:adapter => :bunny, :serializer => :message_pack) do |conn|
  producer = conn.new_producer(
    :exchange => {
      :name => "time",
      :type => :topic
    },
    :message => {
      :routing_key => "time.now"
    }
  )

  consumer = conn.new_consumer(
    :queue => {
      :name => "print_time_now"
    },
    :exchange => {
      :name => "time",
      :routing_key => "time.#"
    }
  )

  consumer.subscribe do |delivery_info, metadata, payload|
    puts "Received message: #{payload}"
  end

  producer.publish Time.now.to_s

  sleep 1
end
```

You could maintain a global connection by using the `connect` method on
`MessageQueue`.

```ruby
MessageQueue.connect(:adater => :bunny, :serializer => :json)
puts MessageQueue.connected? # => true

producer = MessageQueue.new_producer(
  :exchange => {
    :name => "time",
    :type => :topic
  },
  :message => {
    :routing_key => "time.now"
  }
)

consumer = MessageQueue.new_consumer(
  :queue => {
    :name => "print_time_now"
  },
  :exchange => {
    :name => "time",
    :routing_key => "time.#"
  }
)

consumer.subscribe do |delivery_info, metadata, payload|
  puts "Received message: #{payload}"
end

producer.publish Time.now.to_s

sleep 1

MessageQueue.disconnect
puts MessageQueue.connected? # => false
```

You could also mix in the `MessageQueue::Producible` module and the
`MessageQueue::Consumable` module to your producer and consumer
respectively. The consumer needs to implement a `process`
method which will be passed a `MessageQueue::Message` object when it
receives a message.

```ruby
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

MessageQueue.connect(:adater => :bunny, :serializer => :json)
Producer.new.publish(Time.now.to_s)

sleep 1

MessageQueue.disconnect
```

## Examples

See [examples](https://github.com/jingweno/message_queue/tree/master/examples).

## Rails

For Rails, `message_queue` automatically loads settings from
`RAILS_ROOT/config/message_queue.yml`. If the file doesn't exist, it
initializes the queue with in-memory mode.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
