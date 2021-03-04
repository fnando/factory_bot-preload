# frozen_string_literal: true

module FactoryBot
  module Preload
    module Helpers
      def self.included(_base)
        ::FactoryBot::Preload::FixtureCreator.tables.each_key do |table|
          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            # def users(name)
            #   fixture_get(name, User, :users)
            # end
            def #{table}(name)
              fixture_get(name, #{table.to_s.classify}, :#{table})
            end
          RUBY
        end
      end

      private def fixture_get(name, model, table)
        if (record_id = Preload::FixtureCreator.record_ids.dig(table, name) || Preload::FixtureCreator.force_load_fixture(table, name))
          model.find(record_id)
        else
          raise "Couldn't find #{name.inspect} fixture for #{model.name.inspect} model"
        end
      end
    end
  end
end

