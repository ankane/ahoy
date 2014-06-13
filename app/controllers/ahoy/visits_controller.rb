module Ahoy
  class VisitsController < BaseController

    def create
      render json: ahoy.track_visit
    end

  end
end
