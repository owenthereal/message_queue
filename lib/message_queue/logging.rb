require "logger"
require "time"

module MessageQueue
  module Logging
    class Formatter < Logger::Formatter
      def call(severity, time, program_name, message)
        "#{time.utc.iso8601} #{Process.pid} #{severity} -- #{message}\n"
      end
    end

    def self.setup_logger(target = $stdout)
      @logger = Logger.new(target)
      @logger.formatter = Formatter.new
      @logger
    end

    def self.logger
      @logger || setup_logger
    end

    def self.logger=(logger)
      @logger = logger
    end

    def logger
      Logging.logger
    end

    def log_exception(ex)
      logger.error "#{self.class.name} Error: #{ex.class} - #{ex.message}"
      logger.error (['backtrace:'] + ex.backtrace).join("\n")
    end
  end
end
