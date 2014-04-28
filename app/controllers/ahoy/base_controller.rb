module Ahoy
  class BaseController < ApplicationController
    # skip all filters
    skip_filter *_process_action_callbacks.map(&:filter)

    before_filter :halt_bots

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
