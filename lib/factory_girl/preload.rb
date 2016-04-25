require "factory_girl"
require "active_record"

module FactoryGirl
  module Preload
    require "factory_girl/preload/helpers"
    require "factory_girl/preload/version"

    require "factory_girl/preload/rspec2" if defined?(RSpec)
    require "factory_girl/preload/extension"

    ActiveSupport.on_load(:after_initialize) do
      ::FactoryGirl::SyntaxRunner.send(:include, Helpers)
    end

    class << self
      attr_accessor :preloaders
      attr_accessor :factories
      attr_accessor :record_ids
      attr_accessor :clean_with
    end

    self.preloaders = []
    self.factories = {}
    self.record_ids = {}
    self.clean_with = :truncation

    def self.active_record
      ActiveRecord::Base
    end

    def self.connection
      active_record.connection
    end

    def self.run
      helper = Object.new.extend(Helpers)

      connection.transaction :requires_new => true do
        preloaders.each do |block|
          helper.instance_eval(&block)
        end
      end
    end

    def self.clean(*names)
      query = case clean_with
        when :truncation then try_truncation_query
        when :deletion then "DELETE FROM %s"
        else raise "Couldn't find #{clean_with} clean type"
      end

      names = active_record.descendants.select(&:table_exists?).collect(&:table_name).uniq if names.empty?

      connection.disable_referential_integrity do
        names.each do |table|
          begin
            connection.execute(query % connection.quote_table_name(table))
          rescue ActiveRecord::StatementInvalid
            next
          end
        end
      end
    end

    def self.reload_factories
      factories.each do |class_name, group|
        group.each do |name, factory|
          factories[class_name][name] = nil
        end
      end
    end

    private
    def self.try_truncation_query
      case connection.adapter_name
        when "SQLite"     then "DELETE FROM %s"
        when "PostgreSQL" then "TRUNCATE TABLE %s RESTART IDENTITY CASCADE"
        else "TRUNCATE TABLE %s"
      end
    end
  end
end
