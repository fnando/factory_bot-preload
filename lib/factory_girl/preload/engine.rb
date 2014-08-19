require "rails/engine"

module FactoryGirl
  module Preload
    class Engine < Rails::Engine
      ActiveSupport.on_load(:after_initialize, yield: true) do
        require "pry"; binding.pry
        ::FactoryGirl::SyntaxRunner.send(:include, Helpers)
      end

      initializer "factory_girl-preload" do

      end
    end
  end
end
