require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/message_pack"

class MessagePackTest < Test::Unit::TestCase
  def test_dump_and_load
    dump = MessageQueue::Serializers::MessagePack.dump "foo" => "bar"
    loaded = MessageQueue::Serializers::MessagePack.load dump
    assert_equal "bar", loaded["foo"]
  end
end
