module MessageQueue
  def self.hook_rails!
    MessageQueue::Logging.logger = ::Rails.logger

    config_file = ::Rails.root.join("config", "message_queue.yml")
    config = if config_file.exist?
               HashWithIndifferentAccess.new YAML.load(ERB.new(File.read(config_file)).result)[::Rails.env]
             else
               { :adapter => :memory, :serializer => :json }
             end
    MessageQueue.connect(config)
  end

  class Rails < ::Rails::Engine
    initializer "message_queue" do
      MessageQueue.hook_rails!
    end
  end if defined?(::Rails)
end
