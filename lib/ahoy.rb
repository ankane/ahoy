require "active_support"
require "active_support/core_ext"
require "addressable/uri"
require "browser"
require "geocoder"
require "referer-parser"
require "user_agent_parser"
require "request_store"
require "uuidtools"
require "safely/core"

require "ahoy/version"
require "ahoy/tracker"
require "ahoy/controller"
require "ahoy/model"
require "ahoy/visit_properties"
require "ahoy/properties"
require "ahoy/deckhands/location_deckhand"
require "ahoy/deckhands/request_deckhand"
require "ahoy/deckhands/technology_deckhand"
require "ahoy/deckhands/traffic_source_deckhand"
require "ahoy/deckhands/utm_parameter_deckhand"
require "ahoy/stores/base_store"
require "ahoy/stores/active_record_store"
require "ahoy/stores/active_record_token_store"
require "ahoy/stores/log_store"
require "ahoy/stores/fluentd_store"
require "ahoy/stores/mongoid_store"
require "ahoy/stores/kafka_store"
require "ahoy/stores/kinesis_firehose_store"
require "ahoy/stores/bunny_store"
require "ahoy/engine" if defined?(Rails)
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

  mattr_accessor :max_content_length
  self.max_content_length = 8192

  mattr_accessor :max_events_per_request
  self.max_events_per_request = 10

  mattr_accessor :mount
  self.mount = true

  # no longer used
  mattr_accessor :throttle
  self.throttle = true

  # no longer used
  mattr_accessor :throttle_limit
  self.throttle_limit = 20

  # no longer used
  mattr_accessor :throttle_period
  self.throttle_period = 1.minute

  mattr_accessor :job_queue
  self.job_queue = :ahoy

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

if defined?(Rails)
  ActionController::Base.send :include, Ahoy::Controller
  ActiveRecord::Base.send(:extend, Ahoy::Model) if defined?(ActiveRecord)

  # ensure logger silence will not be added by activerecord-session_store
  # otherwise, we get SystemStackError: stack level too deep
  begin
    require "active_record/session_store/extension/logger_silencer"
  rescue LoadError
    require "ahoy/logger_silencer"
    Logger.send :include, Ahoy::LoggerSilencer

    begin
      require "syslog/logger"
      Syslog::Logger.send :include, Ahoy::LoggerSilencer
    rescue LoadError; end
  end
end
