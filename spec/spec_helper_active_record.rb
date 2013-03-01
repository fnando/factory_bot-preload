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
require File.dirname(__FILE__) + "/support/factories_mongoid"

require "mongoid"

require File.dirname(__FILE__) + "/support/application"

load File.dirname(__FILE__) + "/support/app/db/schema.rb"

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end

FactoryGirl::Preload.run
