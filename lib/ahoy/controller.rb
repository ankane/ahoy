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
      @current_visitor_token ||= request.headers["Ahoy-Visitor"] || cookies[:ahoy_visitor] || current_visit.try(:visitor_token) || Ahoy.generate_id
    end

    def set_ahoy_visitor_cookie
      if !request.headers["Ahoy-Visitor"] && !cookies[:ahoy_visitor]
        cookie = {
          value: current_visitor_token,
          expires: 2.years.from_now
        }
        cookie[:domain] = Ahoy.domain if Ahoy.domain
        cookies[:ahoy_visitor] = cookie
      end
    end

  end
end
