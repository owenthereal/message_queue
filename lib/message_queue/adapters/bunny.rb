require "bunny"
require "singleton"

module MessageQueue
  module Adapters
    class Bunny
      include Singleton

      def new_config(opts = {})
        config = Config.new

        if opts[:url]
          AMQ::Settings.parse_amqp_url(opts[:url]).merge(opts).each do |k, v|
            config.send("#{k}=", v)
          end
        end

        config
      end
    end
  end
end
