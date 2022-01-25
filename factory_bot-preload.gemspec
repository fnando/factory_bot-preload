# frozen_string_literal: true

require "./lib/factory_bot/preload/version"

Gem::Specification.new do |s|
  s.name        = "factory_bot-preload"
  s.version     = FactoryBot::Preload::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/factory_bot-preload"
  s.summary     = "Preload factories (Factory Bot) just like fixtures. " \
                  "It will be easier and, probably, faster!"
  s.description = s.summary
  s.required_ruby_version = ">= 2.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end
  s.require_paths = ["lib"]

  s.add_dependency "activerecord"
  s.add_dependency "factory_bot"

  github_url = "https://github.com/fnando/factory_bot-preload"
  github_tree_url = "#{github_url}/tree/v#{s.version}"

  s.metadata["homepage_uri"] = s.homepage
  s.metadata["bug_tracker_uri"] = "#{github_url}/issues"
  s.metadata["source_code_uri"] = github_tree_url
  s.metadata["changelog_uri"] = "#{github_tree_url}/CHANGELOG.md"
  s.metadata["documentation_uri"] = "#{github_tree_url}/README.md"
  s.metadata["license_uri"] = "#{github_tree_url}/LICENSE.md"
  s.metadata["rubygems_mfa_required"] = "true"

  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest-utils"
  s.add_development_dependency "pry-meta"
  s.add_development_dependency "rails"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-fnando"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
end
