require "ahoy/version"
require "ahoy/controller"
require "addressable/uri"
require "browser"
require "geocoder"
require "referer-parser"

module Ahoy
  class Engine < ::Rails::Engine
    isolate_namespace Ahoy
  end
end

ActionController::Base.send :include, Ahoy::Controller

if defined?(Warden)
  Warden::Manager.after_authentication do |user, auth, opts|
    p user
    p auth.env
    p opts
    request = Rack::Request.new(auth.env)
    if request.cookies["ahoy_visit"]
      visit = Ahoy::Visit.where(visit_token: request.cookies["ahoy_visit"]).first
      visit.user = user
      visit.save!
    end
  end
end
