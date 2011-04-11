class Factory
  module Preload
    module Helpers
      def self.extended(base)
        included(base)
      end

      def self.included(base)
        Dir[Rails.application.root.join("app/models/**/*.rb")].each do |file|
          require_dependency file
        end

        ActiveRecord::Base.descendants.each do |model|
          method_name = model.name.underscore.gsub("/", "_").pluralize

          class_eval <<-RUBY, __FILE__, __LINE__
            def #{method_name}(name)
              factory(name, #{model})
            end
          RUBY
        end
      end

      def factory(name, model = nil, &block)
        if block_given?
          factory_set(name, &block)
        else
          factory_get(name, model)
        end
      end

      private
      def factory_get(name, model)
        factory = Factory::Preload.factories[model.name][name] rescue nil
        raise "Couldn't find #{name.inspect} factory for #{model.name.inspect} model" unless factory
        factory
      end

      def factory_set(name, &block)
        record = block.call
        Factory::Preload.factories[record.class.name] ||= {}
        Factory::Preload.factories[record.class.name][name.to_sym] = record
      end
    end
  end
end
