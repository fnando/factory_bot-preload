# frozen_string_literal: true

require "minitest"
require "factory_bot/syntax/methods"

module FactoryBot
  module Preload
    def self.minitest
      FactoryBot::Preload::Helpers.load_models
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
