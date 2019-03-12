require "minitest"
require "factory_bot/syntax/methods"

module FactoryBot
  module Preload
    def self.minitest
      FactoryBot::Preload.clean
      FactoryBot::Preload.run
    end

    module MinitestSetup
      def setup
        FactoryBot::Preload.reload_factories
        super
      end
    end

    Minitest::Test.include Helpers
    Minitest::Test.prepend MinitestSetup
  end
end
