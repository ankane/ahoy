module Ahoy
  module ControllerExtensions

    def self.included(base)
      base.helper_method :current_visit
    end

    protected

    def current_visit
      if cookies[:ahoy_visit]
        @current_visit ||= Ahoy::Visit.where(visit_token: cookies[:ahoy_visit]).first
        if @current_visit
          @current_visit
        else
          # clear cookie if visits are destroyed
          cookies.delete(:ahoy_visit)
          nil
        end
      end
    end

  end
end
