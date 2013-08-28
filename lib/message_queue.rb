require "message_queue/version"

module MessageQueue
  extend self

  ADAPTERS = [:bunny]

  # Public: Initialize a connection to a message queue.
  #
  # options - The Hash options used to initialize a connection
  #           :adapter - The Symbol adapter, currently only :bunny is supported.
  #           Detailed options see individual adapter implementation.
  #
  # Returns the connection for the specified message queue.
  # Raises a RuntimeError if an adapter can't be found.
  def new_connection(options)
    adapter = load_adapter(options[:adapter])
    raise "Missing adapter #{options[:adapter]}" unless adapter

    adapter.instance.new_connection(options)
  end

  # Internal: Load an adapter by name
  #
  # Returns the adapter
  def load_adapter(name)
    ADAPTERS.each do |a|
      if a.to_s == name.to_s
        require_relative "message_queue/adapters/#{name}"
        klass_name = name.to_s.split("_").map(&:capitalize) * ""
        return MessageQueue::Adapters.const_get(klass_name)
      end
    end

    nil
  end
end
