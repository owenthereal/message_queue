module MessageQueue
  class ConsumableRunner
    include Logging

    attr_reader :consumables

    def initialize(consumables)
      @consumables = consumables
    end

    def run(options = {})
      begin
        block = !!options[:block]
        consumables.each_with_index do |consumable, index|
          # Blocks the last consumer
          opts = if index < consumables.size - 1
                   {}
                 else
                   { :block => block }
                 end
          consumable.new.subscribe(opts)
        end
      rescue SignalException => ex
        logger.info "Received Signal #{ex}"
      end
    end
  end
end
