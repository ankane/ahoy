module Ahoy
  module ControllerExtensions

    def self.included(base)
      base.helper_method :current_visit
    end

    protected

    def current_visit
      @current_visit ||= Ahoy::Visit.where(visit_token: cookies[:ahoy_visit]).first if cookies[:ahoy_visit]
    end

  end
end
