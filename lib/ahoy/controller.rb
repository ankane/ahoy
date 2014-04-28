module Ahoy
  module Controller

    def self.included(base)
      base.helper_method :current_visit
      base.before_filter do
        RequestStore.store[:ahoy_controller] ||= self
      end
    end

    def current_visit
      visit_token = cookies[:ahoy_visit] || request.headers["Ahoy-Visit"]
      if visit_token
        @current_visit ||= Ahoy.visit_model.where(visit_token: visit_token).first
      end
    end

  end
end
