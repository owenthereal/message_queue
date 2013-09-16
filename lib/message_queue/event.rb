module MessageQueue
  class Event
    attr_reader :type

    def initialize(options = {})
      @type = options.fetch(:type)
    end

    def attributes
      { :type => type }
    end
  end
end
