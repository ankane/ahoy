module Ahoy
  class BaseController < ApplicationController
    # skip all filters except for authlogic
    filters = _process_action_callbacks.map(&:filter) - [:load_authlogic]
    if Rails::VERSION::MAJOR >= 5
      skip_before_action(*filters, raise: false)
      skip_after_action(*filters, raise: false)
      skip_around_action(*filters, raise: false)
      before_action :verify_request_size
    elsif respond_to?(:skip_action_callback)
      skip_action_callback *filters
      before_action :verify_request_size
    else
      skip_filter *filters
      before_filter :verify_request_size
    end

    if respond_to?(:protect_from_forgery)
      protect_from_forgery with: :null_session, if: -> { Ahoy.protect_from_forgery }
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
