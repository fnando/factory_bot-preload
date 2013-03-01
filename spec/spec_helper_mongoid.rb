ENV["RAILS_ENV"] = "test"
require "rails"

ENV["BUNDLE_GEMFILE"] = File.dirname(__FILE__) + "/../Gemfile"
require "bundler"
Bundler.setup
require "action_controller/railtie"

require File.dirname(__FILE__) + "/../lib/factory_girl-preload"

require "rspec/rails"
require "factory_girl"
require File.dirname(__FILE__) + "/support/factories_mongoid"

require "mongoid"
require "database_cleaner"

require File.dirname(__FILE__) + "/support/application"

RSpec.configure do |config|
  config.after(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with :truncation
    DatabaseCleaner[:mongoid].clean
  end
end

