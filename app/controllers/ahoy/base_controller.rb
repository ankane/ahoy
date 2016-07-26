module Ahoy
  class BaseController < ApplicationController
    # skip all filters except for authlogic
    filters = _process_action_callbacks.map(&:filter) - [:load_authlogic]
    if respond_to?(:skip_before_action)
      skip_before_action(*filters, raise: false)
      skip_after_action(*filters, raise: false)
      skip_around_action(*filters, raise: false)
      before_action :verify_request_size
    else
      skip_filter *filters
      before_filter :verify_request_size
    end

    protected

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self, api: true)
    end

    def verify_request_size
      if request.content_length > Ahoy.max_content_length
        logger.info "[ahoy] Payload too large"
        render text: "Payload too large\n", status: 413
      end
    end
  end
end
