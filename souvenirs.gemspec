# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "souvenirs/version"

Gem::Specification.new do |s|
  s.name        = "souvenirs"
  s.version     = Souvenirs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Mathieu Lajugie"]
  s.email       = ["mathieu.l AT gmail.com"]
  s.homepage    = "https://github.com/mathieul/souvenirs"
  s.summary     = %q{Simple way to persist Ruby objects into the Redis data structure server.}
  s.description = s.summary

  s.rubyforge_project = "souvenirs"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "redis"
  s.add_dependency "activesupport"
  s.add_dependency "activemodel"
  s.add_development_dependency "rspec"
end
