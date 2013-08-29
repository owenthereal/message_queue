require "bunny"
require "singleton"
require "message_queue/adapters/bunny/connection"
require "message_queue/adapters/bunny/publisher"

module MessageQueue
  module Adapters
    class Bunny
      include Singleton

      # Public: Initialize a RabbitMQ connection.
      #
      # options - The Hash options used to initialize a connection.
      #           :uri - The String URI described in http://rubybunny.info/articles/connecting.html.
      #
      # Returns MessageQueue::Adapters::Bunny::Connection if the options are valid.
      # Raises ArgumentError when connection URI schema is not amqp or amqps, or the path contains multiple segments.
      def new_connection(options = {})
        settings = options[:uri] ? AMQ::Settings.parse_amqp_url(options[:uri]).merge(options) : options
        Connection.new(settings)
      end
    end
  end
end
