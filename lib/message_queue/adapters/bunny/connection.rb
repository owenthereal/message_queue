module MessageQueue
  module Adapters
    class Bunny
      class Connection
        attr_reader :settings

        def initialize(settings)
          @settings = settings
        end

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
      end
    end
  end
end
