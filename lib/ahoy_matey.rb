require "addressable/uri"
require "browser"
require "geocoder"
require "referer-parser"
require "user_agent_parser"
require "request_store"
require "ahoy/version"
require "ahoy/controller"
require "ahoy/model"
require "ahoy/engine"

module Ahoy

  def self.visit_model
    @visit_model || ::Visit
  end

  def self.visit_model=(visit_model)
    @visit_model = visit_model
  end

  # TODO private
  # performance hack for referer-parser
  def self.referrer_parser
    @referrer_parser ||= RefererParser::Referer.new("https://github.com/ankane/ahoy")
  end

  # performance
  def self.user_agent_parser
    @user_agent_parser ||= UserAgentParser::Parser.new
  end

  def self.fetch_user(controller)
    if user_method.respond_to?(:call)
      user_method.call(controller)
    else
      controller.send(user_method)
    end
  end

  mattr_accessor :user_method
  self.user_method = proc do |controller|
    (controller.respond_to?(:current_user) && controller.current_user) || (controller.respond_to?(:current_resource_owner, true) && controller.send(:current_resource_owner)) || nil
  end

end

ActionController::Base.send :include, Ahoy::Controller
ActiveRecord::Base.send(:extend, Ahoy::Model) if defined?(ActiveRecord)

if defined?(Warden)
  Warden::Manager.after_set_user except: :fetch do |user, auth, opts|
    request = ActionDispatch::Request.new(auth.env)
    visit_token = request.cookies["ahoy_visit"] || request.headers["Ahoy-Visit"]
    if visit_token
      visit = Ahoy.visit_model.where(visit_token: visit_token).first
      if visit and !visit.user
        visit.user = user
        visit.save!
      end
    end
  end
end
