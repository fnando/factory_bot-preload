require "rspec/core"

RSpec.configure do |config|
  config.include FactoryGirl::Preload::Helpers
  config.before(:suite) do
    FactoryGirl::Preload.clean
    FactoryGirl::Preload.run
  end

  config.before(:each) do
    FactoryGirl::Preload.reload_factories
  end
end
