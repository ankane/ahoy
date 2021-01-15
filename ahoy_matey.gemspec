require_relative "lib/ahoy/version"

Gem::Specification.new do |spec|
  spec.name          = "ahoy_matey"
  spec.version       = Ahoy::VERSION
  spec.summary       = "Simple, powerful, first-party analytics for Rails"
  spec.homepage      = "https://github.com/ankane/ahoy"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib,vendor}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency "activesupport", ">= 5"
  spec.add_dependency "geocoder", ">= 1.4.5"
  spec.add_dependency "safely_block", ">= 0.2.1"
  spec.add_dependency "device_detector"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "pg"
  spec.add_development_dependency "mysql2"
  spec.add_development_dependency "mongoid"
  spec.add_development_dependency "browser", "~> 2.0"
  spec.add_development_dependency "user_agent_parser"
end
