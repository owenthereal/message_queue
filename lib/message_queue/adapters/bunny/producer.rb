class MessageQueue::Adapters::Bunny::Connection::Producer < MessageQueue::Producer
  attr_reader :exchange
  attr_reader :exchange_options, :exchange_name, :exchange_type
  attr_reader :message_options

  # Public: Initialize a new Bunny producer.
  #
  # connection - The Bunny Connection.
  # options    - The Hash options used to initialize the exchange
  #              of a producer:
  #              :exchange -
  #                 :name    - The String exchange name.
  #                 :type    - The Symbol exchange type.
  #                 :durable - The Boolean exchange durability.
  #              :message -
  #                 :routing_key - The String message routing key.
  #                 :persistent  - The Boolean indicate if the
  #                 message persisted to disk .
  #              Detailed options see
  #              https://github.com/ruby-amqp/bunny/blob/master/lib/bunny/exchange.rb.
  #
  # Returns a Publisher.
  def initialize(connection, options = {})
    super

    @connection = connection
    @exchange_options = self.options.fetch(:exchange)
    @exchange_name = exchange_options.delete(:name) || (raise "Missing exchange name")
    @exchange_type = exchange_options.delete(:type) || (raise "Missing exchange type")
    @message_options = self.options.fetch(:message)

    return unless connection.verify_connection

    @exchange = connection.connection.default_channel.send(exchange_type, exchange_name, exchange_options)
  end

  def publish(object, options = {})
    return false unless exchange

    options = message_options.merge(default_options).merge(options)
    object = dump_object(object)

    exchange.publish(object, options)
  end
end
