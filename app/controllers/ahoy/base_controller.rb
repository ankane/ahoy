module Ahoy
  class BaseController < ApplicationController
    # skip all filters
    skip_filter *_process_action_callbacks.map(&:filter)

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self, api: true)
    end

  end
end
