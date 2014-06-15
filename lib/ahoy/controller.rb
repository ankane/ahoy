module Ahoy
  module Controller

    def self.included(base)
      base.helper_method :current_visit
      base.helper_method :ahoy
      base.helper_method :visit_token
      base.helper_method :visitor_token
      base.before_filter :set_ahoy_visitor_cookie
      base.before_filter do
        RequestStore.store[:ahoy_controller] ||= self
      end
    end

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self)
    end

    def current_visit
      ahoy.current_visit
    end

    def visit_token
      ahoy.visit_token
    end

    def visitor_token
      ahoy.visitor_token
    end

    def set_ahoy_visitor_cookie
      ahoy.set_visitor_cookie
    end

  end
end
