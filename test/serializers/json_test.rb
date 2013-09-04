require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/json"

class JsonTest < Test::Unit::TestCase
  def test_dump_and_load
    dump = MessageQueue::Serializers::Json.dump "foo" => "bar"
    loaded = MessageQueue::Serializers::Json.load dump
    assert_equal "bar", loaded["foo"]
  end
end
