class MessageQueue::Adapters::Bunny::Connection::Consumer
  attr_reader :connection
  attr_reader :queue_options, :queue_name
  attr_reader :exchange_options, :exchange_name, :exchange_routing_key
  attr_reader :subscribe_options

  # Public: Initialize a new Bunny consumer.
  #
  # connection - The Bunny Connection.
  # options    - The Hash options used to initialize the exchange
  #              of a consumer:
  #              :queue -
  #                 :name    - The String queue name.
  #                 :durable - The Boolean queue durability.
  #              :exchange -
  #                 :name        - The String exchange name.
  #                 :routing_key - The String exchange routing key.
  #              :subscribe -
  #                 :ack   - The Boolean indicate if it acks.
  #                 :block - The Boolean indicate if it blocks.
  #              Detailed options see
  #              https://github.com/ruby-amqp/bunny/blob/master/lib/bunny/queue.rb
  #              and
  #              https://github.com/ruby-amqp/bunny/blob/master/lib/bunny/exchange.rb.
  #
  # Returns a Consumer.
  def initialize(connection, options = {})
    @connection = connection

    options = options.dup

    @queue_options = options.fetch(:queue)
    @queue_name = queue_options.delete(:name) || (raise "Missing queue name")

    @exchange_options = options.fetch(:exchange)
    @exchange_name = exchange_options.delete(:name) || (raise "Missing exchange name")
    @exchange_routing_key = exchange_options.delete(:routing_key) || queue_name

    @subscribe_options = options.fetch(:subscribe, {})
  end

  def subscribe(options = {}, &block)
    @subscription = queue.subscribe(subscribe_options.merge(options)) do |delivery_info, metadata, payload|
      block.call(delivery_info, metadata, connection.serializer.load(payload))
    end
  end

  def unsubscribe
    @subscription.cancel if @subscription
  end

  def queue
    @queue ||= channel.queue(queue_name, queue_options).bind(exchange_name, :routing_key => exchange_routing_key)
  end

  private

  def channel
    connection.connection.create_channel
  end
end
