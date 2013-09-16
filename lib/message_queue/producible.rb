module MessageQueue
  module Producible
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

    def publish(object, options = {})
      producer = MessageQueue.new_producer(:exchange => self.class.exchange_options, :message => self.class.message_options)
      producer.publish(object, options)
    end
  end
end
