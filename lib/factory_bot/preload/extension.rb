# frozen_string_literal: true

module FactoryBot
  module Syntax
    module Default
      class DSL
        def preload(table, &block)
          ::FactoryBot::Preload::FixtureCreator.tables[table] ||= []
          ::FactoryBot::Preload::FixtureCreator.tables[table] << block
        end
      end
    end
  end
end
