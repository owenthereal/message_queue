# MessageQueue

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'message_queue'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install message_queue

## Usage

```ruby
connection = MessageQueue.new_connection(:adapter => :bunny,
                                         :serializer => :message_pack,
                                         :uri => "amqp://user:pass@host/vhost")
connection.connect

publisher = connection.new_publisher(opts)
publisher.publish(data, opts)

consumer = connection.new_consumer(opts)
consumer.subscribe(opts) do
  # do stuff
end

connection.disconnect
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
