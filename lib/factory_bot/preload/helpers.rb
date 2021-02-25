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

      def fixture(name, model = nil, &block)
        if block_given?
          fixture_set(name, &block)
        else
          fixture_get(name, model)
        end
      end
      alias :factory :fixture

      private def fixture_get(name, model)
        fixture = Preload.factories[model.name][name]

        if fixture.blank? && Preload.factories[model.name].key?(name)
          fixture = model.find(Preload.record_ids[model.name][name])
          Preload.factories[model.name][name] = fixture
        end

        unless fixture
          raise "Couldn't find #{name.inspect} factory for #{model.name.inspect} model"
        end

        fixture
      end

      private def fixture_set(name, &block)
        record = instance_eval(&block).freeze
        Preload.factories[record.class.name] ||= {}
        Preload.factories[record.class.name][name.to_sym] = record

        Preload.record_ids[record.class.name] ||= {}
        Preload.record_ids[record.class.name][name.to_sym] = record.id
        record
      end
    end
  end
end
