# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["BUNDLE_GEMFILE"] = File.dirname(__FILE__) + "/../Gemfile"
ENV["DATABASE_URL"] = "sqlite3::memory:"

require "bundler/setup"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

require "minitest/utils"

class SampleApplication < ::Rails::Application
  config.api = true
  config.root = __dir__ + "/../spec/support/app"
  config.active_support.deprecation = :log
  config.eager_load = false
end

SampleApplication.initialize!
require "rails/test_help"

ActiveRecord::Migration.verbose = true
ActiveRecord::Base.establish_connection ENV["DATABASE_URL"]
load __dir__ + "/../spec/support/app/db/schema.rb"

module ActiveSupport
  class TestCase
    self.use_instantiated_fixtures = true
  end
end

require "factory_bot/preload"
require __dir__ + "/../spec/support/factories"

FactoryBot::Preload.minitest
