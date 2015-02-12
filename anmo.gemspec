# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "anmo/version"

Gem::Specification.new do |s|
  s.name        = "anmo"
  s.version     = Anmo::VERSION
  s.authors     = ["Andrew Vos"]
  s.email       = ["andrew.vos@gmail.com"]
  s.homepage    = ""
  s.summary     = ""
  s.description = ""

  s.rubyforge_project = "anmo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rack"
  s.add_runtime_dependency "thin", "1.6.3"
  s.add_runtime_dependency "httparty"
  s.add_runtime_dependency "dalli"

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "rspec"
end
