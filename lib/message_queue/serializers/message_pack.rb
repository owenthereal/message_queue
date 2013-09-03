require "msgpack"

module MessageQueue
  module Serializers
    class MessagePack < Serializer
      def load(string, options = {})
        ::MessagePack.unpack(string)
      end

      def dump(object, options = {})
        ::MessagePack.pack(object)
      end
    end
  end
end
