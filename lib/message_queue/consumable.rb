require "message_queue/logging"

module MessageQueue
  # A module to mix in a consumer class, for example:
  #
  # class Consumer
  #   include MessageQueue::Consumable
  #
  #   queue :name => "print_time_now"
  #   exchange :name => "time", :routing_key => "time.#"
  #
  #   def process(message)
  #     ...
  #   end
  # end
  #
  # The consumer class needs to implement the process method which will be passed
  # a MessageQueue::Message instance when it receives a message.
  module Consumable
    include Logging

    def self.included(base)
      base.extend(ClassMethods)
      MessageQueue.register_consumable(base)
    end

    module ClassMethods
      def queue(options = {})
        queue_options.merge!(options)
      end

      def exchange(options = {})
        exchange_options.merge!(options)
      end

      def subscribe(options = {})
        subscribe_options.merge!(options)
      end

      def queue_options
        @queue_options ||= {}
      end

      def exchange_options
        @exchange_options ||= {}
      end

      def subscribe_options
        @subscribe_options ||= {}
      end
    end

    def initialize
      @consumer = MessageQueue.new_consumer(:queue => self.class.queue_options,
                                            :exchange => self.class.exchange_options,
                                            :subscribe => self.class.subscribe_options)
    end

    def subscribe(options = {})
      @consumer.subscribe(options) do |message|
        begin
          # message.routing_key randomly becomes encoded in ASCII-8BIT which causes the following:
          # Encoding::CompatibilityError - incompatible character encodings: ASCII-8BIT and UTF-8
          message.routing_key.force_encoding("UTF-8")
          logger.info("Message(#{message.message_id || '-'}): " +
                      "routing key: #{message.routing_key}, " +
                      "type: #{message.type}, " +
                      "timestamp: #{message.timestamp}, " +
                      "consumer: #{@consumer.class}, " +
                      "payload: #{message.payload}")
          process(message)
        rescue StandardError => ex
          handle_error(message, @consumer, ex)
        end
      end
    end

    private

    def handle_error(message, consumer, ex)
      MessageQueue.error_handlers.each do |handler|
        handler.handle(message, consumer, ex)
      end
    end
  end
end
