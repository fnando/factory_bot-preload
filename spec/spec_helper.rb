ENV["RAILS_ENV"] = "test"
require "rails"

ENV["BUNDLE_GEMFILE"] = File.dirname(__FILE__) + "/../Gemfile"
require "bundler"
Bundler.setup
require "rails/all"
Bundler.require(:default)

require "rspec/rails"
require "factory_girl"
require File.dirname(__FILE__) + "/support/factories"

module RSpec
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__) + "/support/app"
    config.active_support.deprecation = :log
    # config.active_record.logger = Logger.new(STDOUT)
  end
end

RSpec::Application.initialize!
load File.dirname(__FILE__) + "/support/app/db/schema.rb"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

Factory.preload do
  factory(:john) { Factory(:user) }
  factory(:ruby) { Factory(:skill, :user => users(:john)) }
end

Factory::Preload.run
