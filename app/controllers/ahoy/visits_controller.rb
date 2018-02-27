module Ahoy
  class VisitsController < BaseController
    def create
      ahoy.track_visit

      # set proper ttl if cookie generated from JavaScript
      set_ahoy_cookies if params[:js] && !Ahoy.api_only

      render json: {
        visit_token: ahoy.visit_token,
        visitor_token: ahoy.visitor_token,
        # legacy
        visit_id: ahoy.visit_token,
        visitor_id: ahoy.visitor_token
      }
    end
  end
end
