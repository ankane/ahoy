require "addressable/uri"
require "browser"
require "geocoder"
require "referer-parser"
require "user_agent_parser"
require "request_store"

require "ahoy/version"
require "ahoy/tracker"
require "ahoy/controller"
require "ahoy/model"
require "ahoy/request"
require "ahoy/extractors/traffic_source_extractor"
require "ahoy/extractors/utm_parameter_extractor"
require "ahoy/extractors/technology_extractor"
require "ahoy/extractors/location_extractor"
require "ahoy/stores/base_store"
require "ahoy/stores/active_record_store"
require "ahoy/stores/log_store"
require "ahoy/stores/mongoid_store"
require "ahoy/engine"
require "ahoy/warden" if defined?(Warden)

module Ahoy
  mattr_accessor :quiet
  self.quiet = true

  mattr_accessor :domain # cookies
end

ActionController::Base.send :include, Ahoy::Controller
ActiveRecord::Base.send(:extend, Ahoy::Model) if defined?(ActiveRecord)
