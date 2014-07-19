ENV["RAILS_ENV"] = "test"
require "rails"

ENV["BUNDLE_GEMFILE"] = File.dirname(__FILE__) + "/../Gemfile"
require "bundler/setup"
require "rails/all"

require "rspec/rails"
require "factory_girl"

module RSpec
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__) + "/support/app"
    config.active_support.deprecation = :log
    config.eager_load = false
  end
end

RSpec::Application.initialize!
load File.dirname(__FILE__) + "/support/app/db/schema.rb"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

require "factory_girl/preload"
require File.dirname(__FILE__) + "/support/factories"
FactoryGirl::Preload.run
