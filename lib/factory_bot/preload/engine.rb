require "rails/engine"

module FactoryBot
  module Preload
    class Engine < Rails::Engine
      ActiveSupport.on_load(:after_initialize, yield: true) do
        ::FactoryBot::SyntaxRunner.send(:include, Helpers)
      end

      initializer "factory_bot-preload" do
      end
    end
  end
end
