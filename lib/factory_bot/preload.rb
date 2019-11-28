# frozen_string_literal: true

require "factory_bot"
require "active_record"

module FactoryBot
  module Preload
    require "factory_bot/preload/helpers"
    require "factory_bot/preload/version"
    require "factory_bot/preload/rspec" if defined?(RSpec)
    require "factory_bot/preload/minitest" if defined?(Minitest)
    require "factory_bot/preload/extension"

    ActiveSupport.on_load(:after_initialize) do
      ::FactoryBot::Preload::Helpers.load_models
      ::FactoryBot::SyntaxRunner.include ::FactoryBot::Preload::Helpers
    end

    class << self
      attr_accessor :preloaders
      attr_accessor :factories
      attr_accessor :record_ids
      attr_accessor :clean_with
    end

    self.preloaders = []
    self.factories = {}
    self.record_ids = {}
    self.clean_with = :truncation

    def self.active_record
      ActiveRecord::Base
    end

    def self.connection
      active_record.connection
    end

    def self.run
      helper = Object.new.extend(Helpers)

      connection.transaction requires_new: true do
        preloaders.each do |block|
          helper.instance_eval(&block)
        end
      end
    end

    def self.clean(*names)
      query = case clean_with
              when :truncation
                try_truncation_query
              when :deletion
                "DELETE FROM %s"
              else
                raise "Couldn't find #{clean_with} clean type"
              end

      names = active_record_names if names.empty?

      connection.disable_referential_integrity do
        names.each do |table|
          connection.execute(query % connection.quote_table_name(table))
        end
      end
    end

    def self.active_record_names
      names = active_record.descendants.collect(&:table_name).uniq.compact
      reserved_tables = %w[ar_internal_metadata schema_migrations]
      names.reject {|name| reserved_tables.include?(name) }
    end

    def self.reload_factories
      factories.each do |class_name, group|
        group.each do |name, _factory|
          factories[class_name][name] = nil
        end
      end
    end

    def self.try_truncation_query
      case connection.adapter_name
      when "SQLite"
        "DELETE FROM %s"
      when "PostgreSQL"
        "TRUNCATE TABLE %s RESTART IDENTITY CASCADE"
      else
        "TRUNCATE TABLE %s"
      end
    end
  end
end
