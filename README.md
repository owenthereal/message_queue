# MessageQueue

A common interface to multiple message queues libraries.

## Installation

Add this line to your application's Gemfile:

    gem 'message_queue'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install message_queue

## Usage

### with_connection

`with_connection` initializes a connection using the specified adapter
and serializer, connects to the message queue, runs a block of code and
disconnects.

```ruby
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

  publisher.publish Time.now.to_s

  sleep 1
end
```

You could maintain a global connection by using the `connect` method on
`MessageQueue`.

```ruby
MessageQueue.connect(:adater => :bunny, :serializer => :json)
puts MessageQueue.connected? # => true

publisher = MessageQueue.new_publisher(
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

publisher.publish Time.now.to_s

sleep 1

MessageQueue.disconnect
puts MessageQueue.connected? # => false
```

## Examples

See [examples](https://github.com/jingweno/message_queue/tree/master/examples).

## Rails

For Rails, `message_queue` automatically loads settings from
`RAILS_ROOT/config/message_queue.yml`. If the file doesn't exist, it
initializes the queue in
[memory](https://github.com/jingweno/message_queue/tree/master/lib/message_queue/adapters/memory) mode.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
