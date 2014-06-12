module Ahoy
  module Controller

    def self.included(base)
      base.helper_method :current_visit
      base.helper_method :ahoy
      base.before_filter :set_ahoy_visitor_cookie
      base.before_filter do
        RequestStore.store[:ahoy_controller] ||= self
      end
    end

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self)
    end

    def current_visit
      visit_token = current_visit_token
      if visit_token
        @current_visit ||= Ahoy.visit_model.where(visit_token: visit_token).first
      end
    end

    def current_visit_token
      @current_visit_token ||= request.headers["Ahoy-Visit"] || cookies[:ahoy_visit]
    end

    def current_visitor_token
      @current_visitor_token ||= request.headers["Ahoy-Visitor"] || cookies[:ahoy_visitor] || Ahoy.generate_id
    end

    def set_ahoy_visitor_cookie
      cookies[:ahoy_visitor] = current_visitor_token if !request.headers["Ahoy-Visitor"] && !cookies[:ahoy_visitor]
    end

  end
end
