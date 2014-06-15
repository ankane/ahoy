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
require "ahoy/extractors/traffic_source"
require "ahoy/extractors/utm_parameters"
require "ahoy/extractors/technology"
require "ahoy/extractors/location"
require "ahoy/stores/active_record"
require "ahoy/stores/log"
require "ahoy/stores/mongoid"
require "ahoy/subscribers/active_record"
require "ahoy/engine"
require "ahoy/warden" if defined?(Warden)

module Ahoy
  mattr_accessor :store

  mattr_accessor :quiet
  self.quiet = true

  mattr_accessor :domain # cookies

  # deprecated - functionality in store

  mattr_accessor :user_method
  self.user_method = proc do |controller|
    (controller.respond_to?(:current_user) && controller.current_user) || (controller.respond_to?(:current_resource_owner, true) && controller.send(:current_resource_owner)) || nil
  end

  mattr_accessor :exclude_method

  mattr_accessor :track_bots
  self.track_bots = false

  # deprecated

  mattr_accessor :subscribers
  self.subscribers = []

  def self.visit_model
    @visit_model || ::Visit
  end

  def self.visit_model=(visit_model)
    @visit_model = visit_model
  end

end

ActionController::Base.send :include, Ahoy::Controller
ActiveRecord::Base.send(:extend, Ahoy::Model) if defined?(ActiveRecord)
