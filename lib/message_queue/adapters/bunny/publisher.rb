require "securerandom"

class MessageQueue::Adapters::Bunny::Connection::Publisher
  attr_reader :connection, :exchange
  attr_reader :exchange_options, :exchange_name, :exchange_type
  attr_reader :message_options

  # Public: Initialize a new Bunny publisher.
  #
  # connection - The Bunny Connection.
  # options    - The Hash options used to initialize the exchange
  #              of a publisher:
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
    @connection = connection

    options = options.dup

    @exchange_options = options.fetch(:exchange)
    @exchange_name = exchange_options.delete(:name) || (raise "Missing exchange name")
    @exchange_type = exchange_options.delete(:type) || (raise "Missing exchange type")

    @message_options = options.fetch(:message)

    @exchange = connection.connection.default_channel.send(exchange_type, exchange_name, exchange_options)
  end

  def publish(payload, options = {})
    serializer = connection.serializer
    default_options = { :content_type => serializer.content_type, :timestamp => Time.now.utc.to_i, :message_id => SecureRandom.uuid }
    exchange.publish(serializer.dump(payload), message_options.merge(default_options).merge(options))
  end
end
