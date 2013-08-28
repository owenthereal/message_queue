require_relative "../test_helper"
require_relative "../../lib/message_queue/adapters/bunny"

class BunnyTest < Test::Unit::TestCase
  def test_new_connection
    connection = MessageQueue::Adapters::Bunny.instance.new_connection(
      :uri => "amqp://user:pass@host/vhost",
      :tls_certificates => ["path"])
    assert_equal "amqp", connection.settings[:scheme]
    assert_equal ["path"], connection.settings[:tls_certificates]
  end
end
