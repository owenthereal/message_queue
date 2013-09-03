require "message_queue/version"
require "message_queue/adapter"
require "message_queue/serializer"

module MessageQueue
  extend self

  ADAPTERS = [:bunny]
  SERIALIZERS = [:plain, :message_pack]

  # Public: Initialize a connection to a message queue.
  #
  # options - The Hash options used to initialize a connection
  #           :adapter - The Symbol adapter, currently only :bunny is supported.
  #                      Detailed options see individual adapter implementation.
  #           :serializer - The Symbol serializer for serialization.
  #
  # Returns the connection for the specified message queue.
  # Raises a RuntimeError if an adapter can't be found.
  def new_connection(options = {})
    adapter = load_adapter(options[:adapter])
    raise "Missing adapter #{options[:adapter]}" unless adapter

    serializer = load_serializer(options[:serializer])
    raise "Missing serializer #{options[:serializer]}" unless serializer

    adapter.new_connection(serializer, options)
  end

  # Public: Initialize a connection to a message queue, connect and execute code in a block.
  #
  # options - The Hash options used to initialize a connection
  #           :adapter - The Symbol adapter, currently only :bunny is supported.
  #                      Detailed options see individual adapter implementation.
  #           :serializer - The Symbol serializer for serialization.
  # block   - The code to execute. The connection object with be passed in.
  #
  # Returns nothing
  # Raises a RuntimeError if an adapter can't be found.
  def with_connection(options = {}, &block)
    connection = new_connection(options)
    connection.with_connection(&block)
  end

  # Internal: Load an adapter by name
  #
  # Returns the adapter or nil if it can't find it
  def load_adapter(name)
    ADAPTERS.each do |a|
      if a.to_s == name.to_s
        require_relative "message_queue/adapters/#{name}"
        klass_name = klass_name_for(name)
        return MessageQueue::Adapters.const_get(klass_name)
      end
    end

    nil
  end

  # Internal: Load a serializer by name
  #
  # Returns the serializer or nil if it can't find it
  def load_serializer(name)
    SERIALIZERS.each do |s|
      if s.to_s == name.to_s
        require_relative "message_queue/serializers/#{name}"
        klass_name = klass_name_for(name)
        return MessageQueue::Serializers.const_get(klass_name)
      end
    end

    nil
  end

  # Internal: Return the class name for name
  #
  # Returns the class name for specified string
  def klass_name_for(name)
    name.to_s.split("_").map(&:capitalize) * ""
  end
end
