module RSpec
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__) + "/app"
    config.active_support.deprecation = :log
  end
end

RSpec::Application.initialize!

