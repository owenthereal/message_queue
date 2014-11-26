module MessageQueue
  module ErrorHandlers
    class ConnectionLogger
      include Logging

      def handle(ex)
        log_exception(ex)
      end
    end

    class MessageLogger
      include Logging

      def handle(message, consumer, ex)
        prefix = "Message(#{message.message_id || '-'}): "
        logger.error prefix + "error in consumer '#{consumer}'"

        log_exception(ex)
      end
    end
  end
end

MessageQueue.register_error_handler :connection, MessageQueue::ErrorHandlers::ConnectionLogger.new
MessageQueue.register_error_handler :message, MessageQueue::ErrorHandlers::MessageLogger.new
