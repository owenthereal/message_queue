require_relative "../test_helper"
require_relative "../../lib/message_queue/adapters/bunny"

class BunnyTest < Test::Unit::TestCase
  def test_new_config
    config = MessageQueue::Adapters::Bunny.instance.new_config(:adapter => :bunny,
                                                               :url => "amqp://user:pass@host/vhost",
                                                               :tls_certificates => ["path"])
    assert_equal "amqp", config.scheme
    assert_equal :bunny, config.adapter
  end
end
