require_relative "../test_helper"
require_relative "../../lib/message_queue/serializers/plain"

class PlainTest < Test::Unit::TestCase
  def test_dump_and_load
    dump = MessageQueue::Serializers::Plain.dump "foo" => "bar"
    loaded = MessageQueue::Serializers::Plain.load dump
    assert_equal "bar", loaded["foo"]
  end
end
