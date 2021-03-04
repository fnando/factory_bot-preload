# frozen_string_literal: true

module FactoryBot
  module Preload
    module FixtureCreator

      extend ::FactoryBot::Syntax::Methods
      extend ::FactoryBot::Preload::Helpers

      class << self
        attr_accessor :tables, :record_ids, :fixtures, :fixtures_with_id
      end

      self.tables = {}
      self.record_ids = {}

      module_function

      def load_to_db
        tmp_fixtures = []
        tmp_fixtures_with_id = []

        tables.each do |table, blocks|
          table_preload = TableLoader.new(table)

          blocks.each do |block|
            table_preload.instance_eval(&block)
          end

          tmp_fixtures.concat(table_preload.fixtures)
          tmp_fixtures_with_id.concat(table_preload.fixtures_with_id)
        end

        self.fixtures = tmp_fixtures.to_h
        self.fixtures_with_id = tmp_fixtures_with_id.to_h

        ::ActiveRecord::Base.connection.transaction requires_new: true do
          fixtures_with_id.each do |key, block|
            table, fixture_name = key.split("/")
            fixture_with_id(table.to_sym, fixture_name.to_sym, &block)
          end

          fixtures.each do |key, block|
            table, fixture_name = key.split("/")
            fixture(table.to_sym, fixture_name.to_sym, &block)
          end
        end
      end

      private def force_load_fixture(table, name)
        if (block = fixtures["#{table}/#{name}"] || fixtures_with_id["#{table}/#{name}"])
          fixture(table, name, &block)
        end
      end

      private def fixture(table, name, &block)
        record_ids[table] ||= {}
        record_ids[table][name] ||= instance_eval(&block).id
      end

      private def fixture_with_id(table, name, &block)
        record_id = fixture(table, name, &block)
        ::ActiveRecord::Base.connection.execute <<~SQL
          SELECT setval(pg_get_serial_sequence('#{table}', 'id'), GREATEST(#{record_id}, nextval(pg_get_serial_sequence('#{table}', 'id'))))
        SQL
      end

    end
  end
end
