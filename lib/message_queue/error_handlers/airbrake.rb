begin
  require "airbrake"
rescue LoadError
end

if defined?(Airbrake)
  module MessageQueue
    module ErrorHandlers
      class Airbrake
        def handle(message, consumer, ex)
          params = message.attributes.merge(:pid => Process.pid, :consumer => consumer.inspect)
          ::Airbrake.notify_or_ignore(ex, :parameters => params)
        end
      end
    end
  end

  MessageQueue.register_error_handler :message, MessageQueue::ErrorHandlers::Airbrake.new
end
