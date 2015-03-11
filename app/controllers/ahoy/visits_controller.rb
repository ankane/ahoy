module Ahoy
  class VisitsController < BaseController
    def create
      ahoy.track_visit
      render json: {visit_id: ahoy.visit_id, visitor_id: ahoy.visitor_id}
    end
  end
end
