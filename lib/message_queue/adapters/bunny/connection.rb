module MessageQueue
  module Adapters
    class Bunny
      class Connection
        attr_reader :settings, :connection

        # Public: Initialize a new Bunny connection.
        #
        # settings - The Hash settings used to connect with Bunny.
        #            Details in http://rubybunny.info/articles/connecting.html.
        #
        # Returns a Connection wrapper for Bunny.
        def initialize(settings)
          @settings = settings
        end

        # Public: Connect to RabbitMQ
        #
        def connect
          @connection ||= begin
                            bunny = ::Bunny.new(settings)
                            bunny.start
                            bunny
                          end
        end

        def disconnect
          if @connection
            @connection.close if @connection.open?
            @connection = nil
          end
        end

        def new_publisher(options)
          raise "No connection to RabbitMQ" unless connection

          Publisher.new(self, options)
        end
      end
    end
  end
end