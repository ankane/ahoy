
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ahoy/version"

Gem::Specification.new do |spec|
  spec.name          = "ahoy_matey"
  spec.version       = Ahoy::VERSION
  spec.summary       = "Simple, powerful analytics for Rails"
  spec.homepage      = "https://github.com/ankane/ahoy"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.2"

  spec.add_dependency "railties", ">= 4.2"
  spec.add_dependency "addressable"
  spec.add_dependency "geocoder", ">= 1.4.5"
  spec.add_dependency "browser", "~> 2.0"
  spec.add_dependency "referer-parser", ">= 0.3"
  spec.add_dependency "user_agent_parser"
  spec.add_dependency "request_store"
  spec.add_dependency "safely_block", ">= 0.2.1"
  spec.add_dependency "device_detector"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "mongoid"
end
