# frozen_string_literal: true

require "rspec/core"
require "factory_bot/syntax/methods"

RSpec.configure do |config|
  config.include FactoryBot::Preload::Helpers

  config.before(:suite) do
    ::FactoryBot::Preload.run
  end
end
