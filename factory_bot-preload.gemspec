# frozen_string_literal: true

require "./lib/factory_bot/preload/version"

Gem::Specification.new do |s|
  s.name        = "factory_bot-preload"
  s.version     = FactoryBot::Preload::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nando Vieira"]
  s.email       = ["fnando.vieira@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/factory_bot-preload"
  s.summary     = "Preload factories (Factory Bot) just like fixtures. It will be easier and, probably, faster!"
  s.description = s.summary

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord"
  s.add_dependency "factory_bot"
end
