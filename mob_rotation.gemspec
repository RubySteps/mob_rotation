# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mob_rotation/version"

Gem::Specification.new do |spec|
  spec.name          = "mob_rotation"
  spec.version       = MobRotation::VERSION
  spec.authors       = ["Pat Maddox", "RubySteps Mob Programming Team"]
  spec.email         = ["pat@rubysteps.com"]
  spec.summary       = "Manage a mob list during a mobbing session"
  spec.description   = "Provides an executable to manage a mob list"
  spec.homepage      = "https://github.com/RubySteps/mob_rotation"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"

  spec.add_dependency "colorize", "~> 0.7.4"
end
