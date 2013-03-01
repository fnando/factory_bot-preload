module FactoryGirl
  module Preload
    autoload :Helpers, "factory_girl/preload/helpers"
    autoload :Version, "factory_girl/preload/version"

    require "factory_girl/preload/rspec2" if defined?(RSpec)
    require "factory_girl/preload/extension"

    class << self
      attr_accessor :preloaders
      attr_accessor :factories
      attr_accessor :record_ids
    end

    self.preloaders = []
    self.factories = {}
    self.record_ids = {}

    def self.active_record
      ActiveRecord::Base
    end

    def self.connection
      active_record.connection
    end

    def self.run
      helper = Object.new.extend(Helpers)

      if defined?(ActiveRecord)
        run_for_active_record(helper)
      else
        run_for_mongoid(helper)
      end
    end

    def self.clean(*names)
      clean_active_record_data(names)
      clean_mongoid_data(names)
    end

    def self.reload_factories
      factories.each do |class_name, group|
        group.each do |name, factory|
          factories[class_name][name] = nil
        end
      end
    end

    private

    def self.run_for_active_record(helper)
      connection.transaction :requires_new => true do
        run_preloaders(helper)
      end
    end

    def self.run_for_mongoid(helper)
      run_preloaders(helper)
    end

    def self.run_preloaders(helper)
      preloaders.each do |block|
        helper.instance_eval(&block)
      end
    end

    def self.clean_active_record_data(names)
      return unless defined?(ActiveRecord)

      query = case connection.adapter_name
        when "SQLite"     then "DELETE FROM %s"
        when "PostgreSQL" then "TRUNCATE TABLE %s RESTART IDENTITY CASCADE"
        else "TRUNCATE TABLE %s"
      end

      names = active_record.descendants.collect(&:table_name).uniq if names.empty?

      connection.disable_referential_integrity do
        names.each do |table|
          connection.execute(query % connection.quote_table_name(table))
        end
      end
    end

    def self.clean_mongoid_data(names)
      return unless defined?(Mongoid)

      collections = Mongoid.default_session.collections.select { |c| c.name !~ /^system\./ }

      if names.empty?
        collections.each { |c| c.find.remove_all }
      else
        collections.each { |c| c.find.remove_all if names.include?(c.name) }
      end
    end
  end
end

