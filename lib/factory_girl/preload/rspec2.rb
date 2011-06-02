require 'rspec/core'

RSpec.configure do |config|
  config.include Factory::Preload::Helpers
  config.before(:suite) do
    Factory::Preload.clean
    Factory::Preload.run
  end

  config.before(:each) do
    Factory::Preload.reload_factories
  end
end