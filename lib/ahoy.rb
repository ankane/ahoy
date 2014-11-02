require "addressable/uri"
require "browser"
require "geocoder"
require "referer-parser"
require "user_agent_parser"
require "request_store"
require "uuidtools"
require "errbase"

require "ahoy/version"
require "ahoy/tracker"
require "ahoy/controller"
require "ahoy/model"
require "ahoy/visit_properties"
require "ahoy/deckhands/location_deckhand"
require "ahoy/deckhands/request_deckhand"
require "ahoy/deckhands/technology_deckhand"
require "ahoy/deckhands/traffic_source_deckhand"
require "ahoy/deckhands/utm_parameter_deckhand"
require "ahoy/stores/base_store"
require "ahoy/stores/active_record_store"
require "ahoy/stores/active_record_token_store"
require "ahoy/stores/log_store"
require "ahoy/stores/mongoid_store"
require "ahoy/engine"
require "ahoy/warden" if defined?(Warden)

# background jobs
begin
  require "active_job"
rescue LoadError
  # do nothing
end
require "ahoy/geocode_job" if defined?(ActiveJob)

# deprecated
require "ahoy/subscribers/active_record"

module Ahoy
  UUID_NAMESPACE = UUIDTools::UUID.parse("a82ae811-5011-45ab-a728-569df7499c5f")

  mattr_accessor :visit_duration
  self.visit_duration = 4.hours

  mattr_accessor :visitor_duration
  self.visitor_duration = 2.years

  mattr_accessor :cookie_domain

  mattr_accessor :track_visits_immediately
  self.track_visits_immediately = false

  mattr_accessor :quiet
  self.quiet = true

  mattr_accessor :geocode
  self.geocode = true

  def self.ensure_uuid(id)
    valid = UUIDTools::UUID.parse(id) rescue nil
    if valid
      id
    else
      UUIDTools::UUID.sha1_create(UUID_NAMESPACE, id).to_s
    end
  end

  # deprecated

  mattr_accessor :domain
  mattr_accessor :visit_model
  mattr_accessor :user_method
  mattr_accessor :exclude_method

  mattr_accessor :subscribers
  self.subscribers = []

  mattr_accessor :track_bots
  self.track_bots = false
end

ActionController::Base.send :include, Ahoy::Controller
ActiveRecord::Base.send(:extend, Ahoy::Model) if defined?(ActiveRecord)
