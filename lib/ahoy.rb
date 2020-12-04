require "ipaddr"

# dependencies
require "active_support"
require "active_support/core_ext"
require "geocoder"
require "safely/core"

# modules
require "ahoy/utils"
require "ahoy/base_store"
require "ahoy/controller"
require "ahoy/database_store"
require "ahoy/helper"
require "ahoy/model"
require "ahoy/query_methods"
require "ahoy/tracker"
require "ahoy/version"
require "ahoy/visit_properties"

require "ahoy/engine" if defined?(Rails)

module Ahoy
  mattr_accessor :visit_duration
  self.visit_duration = 4.hours

  mattr_accessor :visitor_duration
  self.visitor_duration = 2.years

  mattr_accessor :cookies
  self.cookies = true

  # TODO deprecate in favor of cookie_options
  mattr_accessor :cookie_domain

  mattr_accessor :cookie_options
  self.cookie_options = {}

  mattr_accessor :server_side_visits
  self.server_side_visits = true

  mattr_accessor :quiet
  self.quiet = true

  mattr_accessor :geocode
  self.geocode = true

  mattr_accessor :max_content_length
  self.max_content_length = 8192

  mattr_accessor :max_events_per_request
  self.max_events_per_request = 10

  mattr_accessor :job_queue
  self.job_queue = :ahoy

  mattr_accessor :api
  self.api = false

  mattr_accessor :api_only
  self.api_only = false

  mattr_accessor :protect_from_forgery
  self.protect_from_forgery = true

  mattr_accessor :preserve_callbacks
  self.preserve_callbacks = [:load_authlogic, :activate_authlogic]

  mattr_accessor :user_method
  self.user_method = lambda do |controller|
    (controller.respond_to?(:current_user, true) && controller.send(:current_user)) || (controller.respond_to?(:current_resource_owner, true) && controller.send(:current_resource_owner)) || nil
  end

  mattr_accessor :exclude_method

  mattr_accessor :track_bots
  self.track_bots = false

  mattr_accessor :bot_detection_version
  self.bot_detection_version = 2

  mattr_accessor :token_generator
  self.token_generator = -> { SecureRandom.uuid }

  mattr_accessor :mask_ips
  self.mask_ips = false

  mattr_accessor :user_agent_parser
  self.user_agent_parser = :device_detector

  mattr_accessor :logger

  def self.log(message)
    logger.info { "[ahoy] #{message}" } if logger
  end

  def self.mask_ip(ip)
    addr = IPAddr.new(ip)
    if addr.ipv4?
      # set last octet to 0
      addr.mask(24).to_s
    else
      # set last 80 bits to zeros
      addr.mask(48).to_s
    end
  end

  def self.instance
    Thread.current[:ahoy]
  end

  def self.instance=(value)
    Thread.current[:ahoy] = value
  end
end

ActiveSupport.on_load(:action_controller) do
  include Ahoy::Controller
end

ActiveSupport.on_load(:active_record) do
  extend Ahoy::Model
end

ActiveSupport.on_load(:action_view) do
  include Ahoy::Helper
end

# Mongoid
# TODO use
# ActiveSupport.on_load(:mongoid) do
#   Mongoid::Document::ClassMethods.include(Ahoy::Model)
# end
if defined?(ActiveModel)
  ActiveModel::Callbacks.include(Ahoy::Model)
end
