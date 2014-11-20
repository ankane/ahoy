module Ahoy
  class BaseController < ApplicationController
    # skip all filters
    skip_filter :skip_filters

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self, api: true)
    end

    private

    def filters_to_allow
      []
    end

    def skip_filters
      BaseController._process_action_callbacks.map(&:filter).reject{ |filter| filters_to_allow.include?(filter) }
    end

  end
end
