# frozen_string_literal: true

require "rspec/core"
require "factory_bot/syntax/methods"

RSpec.configure do |config|
  config.include FactoryBot::Preload::Helpers

  config.before(:suite) do
    FactoryBot::Preload.clean
    FactoryBot::Preload.run
  end

  config.before(:each) do
    FactoryBot::Preload.reload_factories
  end
end
