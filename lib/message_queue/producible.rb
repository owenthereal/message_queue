require "message_queue/logging"

module MessageQueue
  # A module to mix in a producer class, for example:
  #
  # class Producer
  #   include MessageQueue::Producible
  #
  #   exchange :name => "time", :type => :topic
  #   message :routing_key => "time.now", :mandatory => true
  # end
  #
  # Producer.new.publish(Time.now.to_s)
  module Producible
    include Logging

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def exchange(options = {})
        exchange_options.merge!(options)
      end

      def message(options = {})
        message_options.merge!(options)
      end

      def exchange_options
        @exchange_options ||= {}
      end

      def message_options
        @message_options ||= {}
      end
    end

    def initialize
      @producer = MessageQueue.new_producer(:exchange => self.class.exchange_options, :message => self.class.message_options)
    end

    def publish(object, options = {})
      logger.info "Publishing #{object.inspect} with options #{options.inspect}"

      @producer.publish(object, options)
    end
  end
end
