module Ahoy
  class VisitsController < ActionController::Base
    before_filter :halt_bots

    def create
      visit =
        Ahoy.visit_model.new do |v|
          v.visit_token = params[:visit_token]
          v.visitor_token = params[:visitor_token]
          v.ip = request.remote_ip if v.respond_to?(:ip=)
          v.user_agent = request.user_agent if v.respond_to?(:user_agent=)
          v.referrer = params[:referrer] if v.respond_to?(:referrer=)
          v.landing_page = params[:landing_page] if v.respond_to?(:landing_page=)
          v.user = current_user if respond_to?(:current_user) and v.respond_to?(:user=)
        end

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
