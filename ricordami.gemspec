# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ricordami/version"

ruby_version = RUBY_VERSION[0..2].to_f
RUBY_ENGINE = "ruby" unless Object.const_defined?(:RUBY_ENGINE)

Gem::Specification.new do |s|
  s.name        = "ricordami"
  s.version     = Ricordami::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mathieu Lajugie"]
  s.email       = ["mathieu.l AT gmail.com"]
  s.homepage    = "https://github.com/mathieul/ricordami"
  s.summary     = %q{Simple way to persist Ruby objects into the Redis data structure server.}
  s.description =<<-EOD
Ricordami ("Remember me" in Italian) is an attempt at providing a simple
interface to build Ruby objects that can be validated, persisted and
queried in a Redis data structure server.
EOD

  s.rubyforge_project = "ricordami"

  s.files         = `git ls-files -- "*.md" lib examples MIT-LICENSE`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis", "~> 2.2.0"
  s.add_dependency "activesupport", "~> 3.0.0"
  s.add_dependency "activemodel", "~> 3.0.0"
  s.add_dependency "SystemTimer", "~> 1.2.2" if ruby_version < 1.9 && RUBY_PLATFORM != "java"
  s.add_development_dependency "autotest"
  s.add_development_dependency "infinity_test"
  s.add_development_dependency "autotest-growl" if RUBY_PLATFORM =~ /(darwin|java)/
  s.add_development_dependency "rspec"
  s.add_development_dependency "steak"
  s.add_development_dependency "rcov" if RUBY_ENGINE == "ruby" && ruby_version < 1.9
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "thor"
end
