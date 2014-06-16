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
require "ahoy/extractor"
require "ahoy/extractors/traffic_source_extractor"
require "ahoy/extractors/utm_parameter_extractor"
require "ahoy/extractors/technology_extractor"
require "ahoy/extractors/location_extractor"
require "ahoy/stores/base_store"
require "ahoy/stores/active_record_legacy_store"
require "ahoy/stores/active_record_store"
require "ahoy/stores/log_store"
require "ahoy/stores/mongoid_store"
require "ahoy/engine"
require "ahoy/warden" if defined?(Warden)

# deprecated
require "ahoy/subscribers/active_record"

module Ahoy
  mattr_accessor :quiet
  self.quiet = true

  mattr_accessor :domain # cookies

  # deprecated

  mattr_accessor :visit_model

  mattr_accessor :user_method
  self.user_method = proc do |controller|
    (controller.respond_to?(:current_user) && controller.current_user) || (controller.respond_to?(:current_resource_owner, true) && controller.send(:current_resource_owner)) || nil
  end

  mattr_accessor :exclude_method

  mattr_accessor :subscribers
  self.subscribers = []

  mattr_accessor :track_bots
  self.track_bots = false
end

ActionController::Base.send :include, Ahoy::Controller
ActiveRecord::Base.send(:extend, Ahoy::Model) if defined?(ActiveRecord)
