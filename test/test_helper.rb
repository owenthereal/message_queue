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

class TestHandler < TestLogger
  def handle(message, consumer, ex)
    log(ex.message)
  end
end
