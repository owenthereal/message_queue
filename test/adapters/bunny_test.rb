require_relative "../test_helper"
require_relative "../../lib/message_queue/adapters/bunny"

class BunnyTest < Test::Unit::TestCase
  def test_new_connection
    connection = MessageQueue::Adapters::Bunny.instance.new_connection(
      :uri => "amqp://user:pass@host/vhost",
      :tls_certificates => ["path"])
    assert_equal "amqp", connection.settings[:scheme]
    assert_equal ["path"], connection.settings[:tls_certificates]

    connection = MessageQueue::Adapters::Bunny.instance.new_connection
    bunny = connection.connect
    assert bunny.open?

    connection.disconnect
    assert bunny.closed?
  end

  def test_new_publisher
    connection = MessageQueue::Adapters::Bunny.instance.new_connection
    connection.connect

    publisher = connection.new_publisher(
      :exchange => {
        :name => "test",
        :type => :direct
      },
      :message => {
        :routing_key => "test"
      }
    )

    assert_equal "test", publisher.exchange_name
    assert_equal :direct, publisher.exchange_type
    assert_equal "test", publisher.message_routing_key
  end
end
