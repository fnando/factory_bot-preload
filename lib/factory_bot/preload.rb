# frozen_string_literal: true

require "factory_bot"
require "active_record"

module FactoryBot
  module Preload

    class << self
      attr_accessor(
        :preloaders,
        :record_ids,
        :maximise_sequence_names,
        :reserved_tables,
      )
    end

    self.preloaders = []
    self.record_ids = {}
    self.maximise_sequence_names = {}
    self.reserved_tables = %w[
      ar_internal_metadata
      schema_migrations
    ]

    require "factory_bot/preload/helpers"
    require "factory_bot/preload/version"
    require "factory_bot/preload/rspec" if defined?(RSpec)
    require "factory_bot/preload/minitest" if defined?(Minitest)
    require "factory_bot/preload/extension"

    FACTORIES_CHECKSUM_PATH = Rails.root.join("tmp/factories_checksum")
    DUMP_RECORDS_PATH = Rails.root.join("tmp/fixture_records_dump")

    module_function

    def run
      if (new_fixtures_checksum = modified_fixtures?)
        puts "Full load fixtures".yellow

        clean_db
        load_models
        define_fixture_helpers
        load_fixtures_to_db
        update_sequences

        File.binwrite(DUMP_RECORDS_PATH, Marshal.dump(FactoryBot::Preload.record_ids))
        File.write(FACTORIES_CHECKSUM_PATH, new_fixtures_checksum)
      else
        puts "Cache load fixtures".yellow

        FactoryBot::Preload.record_ids = Marshal.load(File.binread(DUMP_RECORDS_PATH))
        define_fixture_helpers
      end
    end

    def modified_fixtures?
      fixtures_checksum = +""
      FactoryBot.definition_file_paths.each do |path|
        directory_path = File.expand_path(path)
        next unless File.directory?(directory_path)

        Dir[File.join(directory_path, "**", "*.rb")].sort.each do |file|
          fixtures_checksum << Digest::MD5.hexdigest(IO.read(file))
        end
      end

      if !File.exist?(FACTORIES_CHECKSUM_PATH) || fixtures_checksum != File.read(FACTORIES_CHECKSUM_PATH)
        fixtures_checksum
      end
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

    def load_fixtures_to_db
      helper = Object.new.extend(Helpers)

      connection.transaction requires_new: true do
        preloaders.each do |block|
          helper.instance_eval(&block)
        end
      end
    end

    def clean_db(*tables)
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

    def update_sequences
      update_sequences =
        Preload.maximise_sequence_names.map { |seq, id|
          "setval('#{seq}', GREATEST(#{id}, nextval('#{seq}')))"
        }.join(",")

      connection.execute("SELECT #{update_sequences}") unless update_sequences.empty?
    end

    def active_record_names
      connection.tables - reserved_tables
    end

    def active_record
      ::ActiveRecord::Base
    end

    def connection
      active_record.connection
    end
  end
end
