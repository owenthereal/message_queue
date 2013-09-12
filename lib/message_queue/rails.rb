module MessageQueue
  def self.hook_rails!
    config_file = ::Rails.root.join("config", "message_queue.yml")
    config = if config_file.exist?
               YAML.load_file(config_file)[::Rails.env]
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
