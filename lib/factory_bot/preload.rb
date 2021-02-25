# frozen_string_literal: true

require "factory_bot"
require "active_record"

module FactoryBot
  module Preload
    class << self
      attr_accessor :preloaders,
                    :record_ids,
                    :fixtures_per_test,
                    :reserved_tables
    end

    self.preloaders = []
    self.record_ids = {}
    self.fixtures_per_test = {}
    self.reserved_tables = %w[
      ar_internal_metadata
      schema_migrations
    ]

    require "factory_bot/preload/helpers"
    require "factory_bot/preload/version"
    require "factory_bot/preload/rspec" if defined?(RSpec)
    require "factory_bot/preload/minitest" if defined?(Minitest)
    require "factory_bot/preload/extension"

    ActiveSupport.on_load(:after_initialize) do
      ::FactoryBot::Preload::Helpers.load_models
      ::FactoryBot::SyntaxRunner.include(::FactoryBot::Preload::Helpers)
    end

    def self.active_record
      ::ActiveRecord::Base
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

    def self.clean(*tables)
      tables = active_record_names if tables.empty?

      query =
        case connection.adapter_name
        when "SQLite"
          tables.map { |table| "DELETE FROM #{connection.quote_table_name(table)}" }.join(";")
        when "PostgreSQL"
          "TRUNCATE TABLE #{tables.map { |table| connection.quote_table_name(table) }.join(',')} RESTART IDENTITY CASCADE"
        else
          "TRUNCATE TABLE #{tables.map { |table| connection.quote_table_name(table) }.join(',')}"
        end

      connection.disable_referential_integrity do
        connection.execute(query)
      end
    end

    def self.active_record_names
      names = active_record.descendants.collect(&:table_name).uniq.compact

      names.reject { |name| reserved_tables.include?(name) }
    end

    def self.reload_factories
      self.fixtures_per_test = {}
    end
  end
end
