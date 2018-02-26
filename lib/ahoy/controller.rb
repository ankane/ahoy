require "request_store"

module Ahoy
  module Controller
    def self.included(base)
      if base.respond_to?(:helper_method)
        base.helper_method :current_visit
        base.helper_method :ahoy
      end
      base.before_action :set_ahoy_cookies, unless: -> { Ahoy.api_only }
      base.before_action :track_ahoy_visit, unless: -> { Ahoy.api_only }
      base.before_action :set_ahoy_request_store
    end

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self)
    end

    def current_visit
      ahoy.visit
    end

    def set_ahoy_cookies
      ahoy.set_visitor_cookie
      ahoy.set_visit_cookie
    end

    def track_ahoy_visit
      if ahoy.new_visit?
        ahoy.track_visit(defer: !Ahoy.server_side_visits)
      end
    end

    def set_ahoy_request_store
      RequestStore.store[:ahoy] ||= ahoy
    end
  end
end
