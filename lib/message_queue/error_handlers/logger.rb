module MessageQueue
  module ErrorHandlers
    class Logger
      include Logging

      def handle(message, consumer, ex)
        prefix = "message(#{message.message_id || '-'}): "
        logger.error prefix + "error in consumer '#{consumer}'"
        logger.error prefix + "#{ex.class} - #{ex.message}"
        logger.error (['backtrace:'] + ex.backtrace).join("\n")
      end
    end
  end
end

MessageQueue.register_error_handler MessageQueue::ErrorHandlers::Logger.new
