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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
