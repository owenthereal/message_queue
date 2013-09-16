module MessageQueue
  # class Consumer
  #   include MessageQueue::Consumerable
  #
  #   queue :name => "print_time_now"
  #   exchange :name => "time", routing_key => "time.#"
  #
  #   def process(*args)
  #     ...
  #   end
  # end
  module Consumable
    def self.included(base)
      base.extend(ClassMethods)
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

    def subscribe(options = {})
      consumer = MessageQueue.new_consumer(:queue => self.class.queue_options,
                                           :exchange => self.class.exchange_options,
                                           :subscribe => self.class.subscribe_options)
      consumer.subscribe(options) do |*args|
        process(*args)
      end
    end
  end
end
