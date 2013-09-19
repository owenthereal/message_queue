module MessageQueue
  class ConsumableRunner
    attr_reader :consumables

    def initialize(consumables)
      @consumables = consumables
    end

    def run(options = {})
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
    end
  end
end
