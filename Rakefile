require "bundler/gem_tasks"

case ENV["TEST_FRAMEWORK"]
when "rspec"
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new

  task :default => :spec
when "minitest"
  require "rake/testtask"

  Rake::TestTask.new(:test) do |t|
    t.libs << "test"
    t.libs << "lib"
    t.test_files = FileList["test/**/*_test.rb"]
    t.verbose = false
    t.warning = false
  end

  task :default => :test
else
  task :default do
    system "TEST_FRAMEWORK=rspec bundle exec rake spec"
    system "TEST_FRAMEWORK=minitest bundle exec rake test"
  end
end
