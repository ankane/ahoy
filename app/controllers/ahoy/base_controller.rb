module Ahoy
  class BaseController < ApplicationController
    # skip all filters except for authlogic
    filters = _process_action_callbacks.map(&:filter) - [:load_authlogic]
    if respond_to?(:skip_action)
      skip_action *filters
    else
      skip_filter *filters
    end

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self, api: true)
    end
  end
end
