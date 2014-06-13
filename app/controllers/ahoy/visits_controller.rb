module Ahoy
  class VisitsController < BaseController

    def create
      visit_token = params[:visit_token] || Ahoy.generate_id
      visitor_token = params[:visitor_token] || Ahoy.generate_id

      visit =
        Ahoy.visit_model.new do |v|
          v.visit_token = visit_token
          v.visitor_token = visitor_token
          v.ip = request.remote_ip if v.respond_to?(:ip=)
          v.user_agent = request.user_agent if v.respond_to?(:user_agent=)
          v.referrer = params[:referrer] if v.respond_to?(:referrer=)
          v.landing_page = params[:landing_page] if v.respond_to?(:landing_page=)
          v.user = Ahoy.fetch_user(self) if v.respond_to?(:user=)
          v.platform = params[:platform] if v.respond_to?(:platform=)
          v.app_version = params[:app_version] if v.respond_to?(:app_version=)
          v.os_version = params[:os_version] if v.respond_to?(:os_version=)
        end

      begin
        visit.save!
      rescue ActiveRecord::RecordNotUnique
        # do nothing
      end
      render json: {visit_token: visit.visit_token, visitor_token: visit.visitor_token}
    end

  end
end
