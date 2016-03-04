require "request_store"

module Ahoy
  module Controller
    def self.included(base)
      base.helper_method :current_visit
      base.helper_method :ahoy
      base.before_action :set_ahoy_cookies
      base.before_action :track_ahoy_visit
      base.before_action do
        RequestStore.store[:ahoy] ||= ahoy
      end
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
        ahoy.track_visit(defer: !Ahoy.track_visits_immediately)
      end
    end
  end
end
