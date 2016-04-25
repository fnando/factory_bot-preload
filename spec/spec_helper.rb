ENV["RAILS_ENV"] = "test"
ENV["BUNDLE_GEMFILE"] = File.dirname(__FILE__) + "/../Gemfile"

require "bundler/setup"
require "rails/all"

module RSpec
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__) + "/support/app"
    config.active_support.deprecation = :log
    config.eager_load = false
  end
end

RSpec::Application.initialize!
ActiveRecord::Migration.verbose = false
load File.dirname(__FILE__) + "/support/app/db/schema.rb"

require "rspec/rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

require "factory_girl"
require "factory_girl/preload"
require File.dirname(__FILE__) + "/support/factories"
