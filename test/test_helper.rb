require "test/unit"
require_relative "../lib/message_queue"

class TestLogger
  attr_reader :buffer

  def initialize(*)
    @buffer = ''
  end

  def log(string)
    @buffer << string
  end

  alias :info :log
  alias :error :log
end

class TestConnectionHandler < TestLogger
  def handle(ex)
    log(ex.message)
  end
end

class TestMessageHandler < TestLogger
  def handle(message, consumer, ex)
    log(ex.message)
  end
end

def start_test_logger
  @original_logger = MessageQueue::Logging.logger
  @test_logger = TestLogger.new
  MessageQueue::Logging.logger = @test_logger

  ErrorBunny::ErrorBunnyConnection.bunny_adapter_class = ErrorBunny::ErrorBunnyAdapter
end

def stop_test_logger
  MessageQueue::Logging.logger = @original_logger
end
