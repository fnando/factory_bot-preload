# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter(/schema\.rb/)
end

ENV["RAILS_ENV"] = "test"
ENV["BUNDLE_GEMFILE"] = "#{File.dirname(__FILE__)}/../Gemfile"
ENV["DATABASE_URL"] = "sqlite3::memory:"

require "bundler/setup"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

module RSpec
  class Application < ::Rails::Application
    config.root = "#{File.dirname(__FILE__)}/support/app"
    config.active_support.deprecation = :log
    config.eager_load = false
  end
end

RSpec::Application.initialize!
ActiveRecord::Migration.verbose = true
ActiveRecord::Base.establish_connection ENV["DATABASE_URL"]
load "#{File.dirname(__FILE__)}/support/app/db/schema.rb"

require "rspec/rails"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

require "factory_bot/preload"
require "#{File.dirname(__FILE__)}/support/factories"
