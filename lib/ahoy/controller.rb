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
      visit_token = current_visit_id
      if visit_token
        @current_visit ||= Ahoy.visit_model.where(visit_token: visit_token).first
      end
    end

    # different from current_visit.id
    # this is confusing, but we must move to UUIDs
    def current_visit_id
      @current_visit_id ||= request.headers["Ahoy-Visit"] || cookies[:ahoy_visit]
    end

    def set_ahoy_visitor_cookie
      cookies[:ahoy_visitor] = current_visitor_id if !request.headers["Ahoy-Visitor"] && !cookies[:ahoy_visitor]
    end

    def current_visitor_id
      @current_visitor_id ||= request.headers["Ahoy-Visitor"] || cookies[:ahoy_visitor] || Ahoy.generate_id
    end

  end
end
