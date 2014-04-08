module Ahoy
  class VisitsController < ActionController::Base
    include Ahoy::Controller::Builder

    before_filter :halt_bots

    def create
      visit = build_visit

      visit.save!
      render json: {id: visit.id}
    end

    protected

    def browser
      @browser ||= Browser.new(ua: request.user_agent)
    end

    def halt_bots
      if browser.bot?
        render json: {}
      end
    end

  end
end
