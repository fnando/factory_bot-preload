# frozen_string_literal: true

module FactoryBot
  module Preload
    class TableLoader

      attr_reader :table, :fixtures, :fixtures_with_id

      def initialize(table)
        @table = table
        @fixtures = []
        @fixtures_with_id = []
      end

      def fixture(name, &block)
        @fixtures << ["#{table}/#{name}", block]
      end

      def fixture_with_id(name, &block)
        @fixtures_with_id << ["#{table}/#{name}", block]
      end

    end
  end
end
