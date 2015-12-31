module Ahoy
  class BaseController < ApplicationController
    # skip all actions except for authlogic
    skip_action(*(_process_action_callbacks.map(&:filter) - [:load_authlogic]))

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self, api: true)
    end
  end
end
