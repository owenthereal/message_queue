require "message_queue/version"
require "ostruct"

module MessageQueue
  extend self

  ADAPTERS = [:bunny]

  def setup(hash_or_file_path)
    if hash_or_file_path.is_a?(String)
      # load from a file
    end

    @config = parse_config(hash_or_file_path)
  end

  def config
    @config
  end

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

  private

  def parse_config(opts)
    adapter = load_adapter(opts[:adapter])
    raise "Missing adapter #{config[:adapter]}" unless adapter

    adapter.instance.new_config(opts)
  end
end

require_relative "message_queue/config"
