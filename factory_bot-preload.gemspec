require "./lib/factory_bot/preload/version"

Gem::Specification.new do |s|
  s.name        = "factory_bot-preload"
  s.version     = FactoryBot::Preload::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/factory_bot-preload"
  s.summary     = "Preload factories (Factory Bot) just like fixtures. It will be easy and, probably, faster!"
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map {|f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord"
  s.add_dependency "factory_bot"

  s.add_development_dependency "bundler"
  s.add_development_dependency "minitest-utils"
  s.add_development_dependency "pry-meta"
  s.add_development_dependency "rails"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "sqlite3", "~> 1.3.6"
end
