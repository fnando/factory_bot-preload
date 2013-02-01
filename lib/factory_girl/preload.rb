module FactoryGirl
  module Preload
    autoload :Helpers, "factory_girl/preload/helpers"
    autoload :Version, "factory_girl/preload/version"

    require "factory_girl/preload/rspec2" if defined?(RSpec)
    require "factory_girl/preload/extension"

    class << self
      attr_accessor :preloaders
      attr_accessor :factories
      attr_accessor :record_ids
    end

    self.preloaders = []
    self.factories = {}
    self.record_ids = {}

    def self.active_record
      ActiveRecord::Base
    end

    def self.connection
      active_record.connection
    end

    def self.run
      helper = Object.new.extend(Helpers)

      connection.transaction :requires_new => true do
        preloaders.each do |block|
          helper.instance_eval(&block)
        end
      end
    end

    def self.clean(*names)
      query = case connection.adapter_name
        when "SQLite"     then "DELETE FROM %s"
        when "PostgreSQL" then "TRUNCATE TABLE %s RESTART IDENTITY CASCADE"
        else "TRUNCATE TABLE %s"
      end

      names = active_record.descendants.collect(&:table_name).uniq if names.empty?

      connection.disable_referential_integrity do
        names.each do |table|
          connection.execute(query % connection.quote_table_name(table))
        end
      end
    end

    def self.reload_factories
      factories.each do |class_name, group|
        group.each do |name, factory|
          factories[class_name][name] = nil
        end
      end
    end
  end
end
