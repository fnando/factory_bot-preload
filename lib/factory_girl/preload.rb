module Factory
  module Preload
    autoload :Helpers, "factory_girl/preload/helpers"
    autoload :Version, "factory_girl/preload/version"

    require "factory_girl/preload/rspec2" if defined?(RSpec)
    require "factory_girl/preload/extension"

    class << self
      attr_accessor :preloaders
      attr_accessor :factories
    end

    self.preloaders = []
    self.factories = {}

    def self.run
      helper = Object.new.extend(Helpers)

      ActiveRecord::Base.connection.transaction :requires_new => true do
        preloaders.each do |block|
          helper.instance_eval(&block)
        end
      end
    end

    def self.clean(*names)
      query = case ActiveRecord::Base.connection.adapter_name
        when "SQLite"     then "DELETE FROM %s"
        when "PostgreSQL" then "TRUNCATE TABLE %s RESTART IDENTITY"
        else "TRUNCATE TABLE %s"
      end
      names = ActiveRecord::Base.descendants.collect(&:table_name).uniq if names.empty?
      names.each {|table| ActiveRecord::Base.connection.execute(query % ActiveRecord::Base.connection.quote_table_name(table))}
    end

    def self.reload_factories
      factories.each do |class_name, group|
        group.each do |name, factory|
          factories[class_name][name] = factory.class.find(factory.id)
        end
      end
    end
  end
end
