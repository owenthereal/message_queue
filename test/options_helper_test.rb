require_relative "test_helper"
require "message_queue/options_helper"

class OptionsHelperTest < Test::Unit::TestCase
  class TestClass
    include OptionsHelper
  end

  def test_deep_clone
    hash = {:foo => :bar}

    obj = TestClass.new
    new_hash = obj.deep_clone(hash)
    assert_equal new_hash, hash

    hash[:foo] = :baz
    assert_not_equal new_hash, hash

    hash_with_block = {:foo => ->() {:bar} }
    new_hash = obj.deep_clone(hash_with_block)
    assert_equal new_hash, {:foo => :bar}
  end
end
