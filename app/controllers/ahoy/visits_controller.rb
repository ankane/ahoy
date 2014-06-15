module Ahoy
  class VisitsController < BaseController

    def create
      ahoy.track_visit
      render json: {visit_token: ahoy.visit_token, visitor_token: ahoy.visitor_token}
    end

  end
end
