module MessageQueue
  class Consumers
    attr_reader :consumables

    def initialize(consumables)
      @consumables = consumables
    end

    def run
      consumables.each_with_index do |consumable, index|
        # Blocks the last consumer
        opts = if index < consumables.size - 1
                 {}
               else
                 { :block => true }
               end
        consumable.subscribe(opts)
      end
    end
  end
end
