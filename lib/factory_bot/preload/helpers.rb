# frozen_string_literal: true

module FactoryBot
  module Preload
    module Helpers
      include ::FactoryBot::Syntax::Methods

      def self.define_helper_methods
        ActiveRecord::Base.connection.tables.each do |table|
          next if ::FactoryBot::Preload.reserved_tables.include?(table)

          module_eval <<-RUBY, __FILE__, __LINE__ + 1
            # def users(name)
            #   fixture_get(name, User)
            # end
            def #{table}(name)
              fixture_get(name, #{table.classify})
            end
          RUBY
        end
      end

      def self.included(_base)
        ::FactoryBot::Preload::Helpers.define_helper_methods
      end

      def fixture(name, &block)
        record = instance_eval(&block)

        Preload.record_ids[record.class.name] ||= {}
        Preload.record_ids[record.class.name][name.to_sym] = record.id
        record
      end

      def fixture_with_id(name, &block)
        record = fixture(name, &block)
        prev_id = Preload.maximise_sequence_names[record.class.sequence_name]
        Preload.maximise_sequence_names[record.class.sequence_name] = [record.id, prev_id || 1].max
        record
      end

      private def fixture_get(name, model)
        if (record_id = Preload.record_ids.dig(model.name, name))
          model.find(record_id)
        else
          raise "Couldn't find #{name.inspect} fixture for #{model.name.inspect} model"
        end
      end
    end
  end
end
