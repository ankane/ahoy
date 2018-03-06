require "active_support"
require "active_support/core_ext"
require "addressable/uri"
require "geocoder"
require "safely/core"

require "ahoy/base_store"
require "ahoy/controller"
require "ahoy/database_store"
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

  mattr_accessor :cookie_domain

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
    (controller.respond_to?(:current_user) && controller.current_user) || (controller.respond_to?(:current_resource_owner, true) && controller.send(:current_resource_owner)) || nil
  end

  mattr_accessor :exclude_method

  mattr_accessor :track_bots
  self.track_bots = false

  mattr_accessor :token_generator
  self.token_generator = -> { SecureRandom.uuid }

  mattr_accessor :automount
  self.automount = true

  def self.log(message)
    Rails.logger.info { "[ahoy] #{message}" }
  end
end

ActiveSupport.on_load(:action_controller) do
  include Ahoy::Controller
end

ActiveSupport.on_load(:active_record) do
  extend Ahoy::Model
end

# Mongoid
if defined?(ActiveModel)
  ActiveModel::Callbacks.include(Ahoy::Model)
end
