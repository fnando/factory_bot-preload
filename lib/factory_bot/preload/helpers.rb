# frozen_string_literal: true

module FactoryBot
  module Preload
    module Helpers
      include ::FactoryBot::Syntax::Methods

      def self.load_models
        return unless defined?(Rails)

        Dir[Rails.application.root.join("app/models/**/*.rb")].each do |file|
          require_dependency file
        end
      end

      def self.define_helper_methods
        ActiveRecord::Base.descendants.each do |model|
          next if ::FactoryBot::Preload.reserved_tables.include?(model.table_name)

          define_method(model.name.tableize) do |name|
            fixture_get(name, model)
          end
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

      def fixture_stub_const(name, const_name, &block)
        record = fixture(name, &block)
        model = record.class
        if model.const_defined?(const_name)
          model.send(:remove_const, const_name)
          model.const_set(const_name, record.id)
        else
          raise ArgumentError, "#{model.name}::#{const_name} is not defined"
        end
        record
      end

      private def fixture_get(name, model)
        per_test_key = "#{model.name}-#{name}"
        fixture = Preload.fixtures_per_test[per_test_key]

        if fixture
          fixture
        elsif (record_id = Preload.record_ids[model.name][name])
          Preload.fixtures_per_test[per_test_key] = model.find(record_id)
        else
          raise "Couldn't find #{name.inspect} fixture for #{model.name.inspect} model"
        end
      end
    end
  end
end
