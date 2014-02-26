module Ahoy
  module ControllerExtensions

    def ahoy_visit
      @ahoy_visit ||= Ahoy::Visit.where(visit_token: cookies[:ahoy_visit]).first if cookies[:ahoy_visit]
    end

  end
end
