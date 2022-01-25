# frozen_string_literal: true

module FactoryBot
  module Preload
    module Helpers
      include ::FactoryBot::Syntax::Methods

      def self.load_models
        return unless defined?(Rails)

        Dir[Rails.application.root.join("app/models/**/*.rb")].sort.each do |file|
          require_dependency file
        end
      end

      def self.define_helper_methods
        ActiveRecord::Base.descendants.each do |model|
          next if FactoryBot::Preload.reserved_tables.include?(model.table_name)

          helper_name = model.name.underscore.tr("/", "_").pluralize

          helper_name = FactoryBot::Preload.helper_name.call(
            model.name,
            helper_name
          )

          define_method(helper_name) do |name|
            factory(name, model)
          end
        end
      end

      def self.included(_base)
        FactoryBot::Preload::Helpers.define_helper_methods
      end

      def factory(name, model = nil, &block)
        if block_given?
          factory_set(name, &block)
        else
          factory_get(name, model)
        end
      end

      private def factory_get(name, model)
        factory = Preload.factories[model.name][name]

        if factory.blank? && Preload.factories[model.name].key?(name)
          factory = model.find(Preload.record_ids[model.name][name])
          Preload.factories[model.name][name] = factory
        end

        unless factory
          raise "Couldn't find #{name.inspect} factory for #{model.name.inspect} model"
        end

        factory
      end

      private def factory_set(name, &block)
        record = instance_eval(&block)
        Preload.factories[record.class.name] ||= {}
        Preload.factories[record.class.name][name.to_sym] = record

        Preload.record_ids[record.class.name] ||= {}
        Preload.record_ids[record.class.name][name.to_sym] = record.id
      end
    end
  end
end
