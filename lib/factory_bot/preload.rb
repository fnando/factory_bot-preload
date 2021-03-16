# frozen_string_literal: true

require "factory_bot"
require "active_record"

module FactoryBot
  module Preload

    require "factory_bot/preload/helpers"
    require "factory_bot/preload/fixture_creator"
    require "factory_bot/preload/table_loader"
    require "factory_bot/preload/version"
    require "factory_bot/preload/rspec" if defined?(RSpec)
    require "factory_bot/preload/minitest" if defined?(Minitest)
    require "factory_bot/preload/extension"

    DUMP_RECORDS_PATH = Rails.root.join("tmp/fixture_records_dump")

    module_function

    def run
      if max_mtime_fixtures > cached_mtime_fixtures
        puts "Full load fixtures".yellow

        clean_db
        load_models
        define_fixture_helpers
        FactoryBot::Preload::FixtureCreator.load_to_db

        File.binwrite(DUMP_RECORDS_PATH, Marshal.dump(FactoryBot::Preload::FixtureCreator.record_ids))
        caching_max_mtime_fixtures
      else
        puts "Cache load fixtures".yellow

        FactoryBot::Preload::FixtureCreator.record_ids = Marshal.load(File.binread(DUMP_RECORDS_PATH))
        define_fixture_helpers
      end
    end

    def max_mtime_fixtures
      @max_mtime_fixtures ||=
        FactoryBot.definition_file_paths.flat_map { |path|
          directory_path = File.expand_path(path)

          if File.directory?(directory_path)
            Dir[File.join(directory_path, "**", "*.rb")].map { |file| File.mtime(file) }
          end
        }.compact.max.round(6)
    end

    def cached_mtime_fixtures
      connection.query_value(<<-SQL) || Time.zone.at(0)
        CREATE TABLE IF NOT EXISTS __factory_bot_preload_cache(fixtures_time timestamptz);
        SELECT * FROM __factory_bot_preload_cache
      SQL
    end

    def caching_max_mtime_fixtures
      connection.execute(<<-SQL)
        TRUNCATE TABLE __factory_bot_preload_cache;
        INSERT INTO __factory_bot_preload_cache VALUES ('#{max_mtime_fixtures.iso8601(6)}')
      SQL
    end

    def load_models
      return unless defined?(Rails)

      Dir[Rails.application.root.join("app/models/**/*.rb")].each do |file|
        require_dependency file
      end
    end

    def define_fixture_helpers
      ::FactoryBot::SyntaxRunner.include(::FactoryBot::Preload::Helpers)
    end

    RESERVED_TABLES = %w[
      ar_internal_metadata
      schema_migrations
    ].freeze

    def clean_db
      tables = connection.tables - RESERVED_TABLES

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

    def connection
      ::ActiveRecord::Base.connection
    end
  end
end
