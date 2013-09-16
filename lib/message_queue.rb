require "message_queue/version"
require "message_queue/adapter"
require "message_queue/connection"
require "message_queue/serializer"

module MessageQueue
  extend self

  attr_reader :connection, :settings

  ADAPTERS = [:memory, :bunny]
  SERIALIZERS = [:plain, :message_pack, :json]

  # Public: Connect to the message queue.
  #
  # It either reads options from a Hash or the path to the Yaml settings file.
  # After connecting, it stores the connection instance locally.
  #
  # file_or_options - The Hash options or the String Yaml settings file
  #                   Detail Hash options see the new_connection method.
  #
  # Returns the connection for the specified message queue.
  # Raises a RuntimeError if an adapter can't be found.
  def connect(file_or_options = {})
    if file_or_options.is_a?(String)
      require "yaml"
      file_or_options = YAML.load_file(file_or_options).inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    end

    @settings = file_or_options
    @connection = new_connection(@settings)
    @connection.connect
  end

  # Public: Disconnect from the message queue if it's connected
  #
  # It clears out the stored connection.
  #
  # Returns true if it disconnects successfully
  def disconnect
    if @connection
      @connection.disconnect
      @connection = nil
      return true
    end

    false
  end

  # Public: Reconnect to the message queue if it's disconnected by using the previous connection settings
  #
  # Returns the new connection if it reconnects successfully
  def reconnect
    disconnect if connected?
    connect(settings)
  end

  # Public: Check if it's connected to the message queue
  #
  # Returns true if it's connected
  def connected?
    connection.connected? if connection
  end

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

  # Public: Initialize a producer using current connection to a message queue.
  #
  # Details options see a particular adapter.
  #
  # Returns a new producer
  def new_producer(options = {})
    connection.new_producer(options)
  end

  # Public: Initialize a consumer using current connection to a message queue.
  #
  # Details options see a particular adapter.
  #
  # Returns a new consumer
  def new_consumer(options = {})
    connection.new_consumer(options)
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

require "message_queue/producible"
require "message_queue/consumable"
require "message_queue/rails" if defined?(::Rails::Engine)
