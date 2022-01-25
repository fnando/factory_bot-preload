# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"

RuboCop::RakeTask.new

case ENV["TEST_FRAMEWORK"]
when "rspec"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new

  task default: %i[spec rubocop]
when "minitest"
  require "rake/testtask"

  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
    t.verbose = false
    t.warning = false
  end

  task default: %i[test rubocop]
else
  task :default do
    system "TEST_FRAMEWORK=rspec bundle exec rake"
    system "TEST_FRAMEWORK=minitest bundle exec rake"
  end
end
