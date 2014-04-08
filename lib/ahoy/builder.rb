module Ahoy
  module Controller
    module Builder
      include Ahoy::StringGenerator

      def build_visit
        params[:visit_token] ||= generate_token
        params[:visitor_token] ||= generate_token

        Ahoy.visit_model.new do |v|
          v.visit_token = params[:visit_token]
          v.visitor_token = params[:visitor_token]
          v.ip = request.remote_ip if v.respond_to?(:ip=)
          v.user_agent = request.user_agent if v.respond_to?(:user_agent=)
          v.referrer = params[:referrer] if v.respond_to?(:referrer=)
          v.landing_page = params[:landing_page] || request.url if v.respond_to?(:landing_page=)
          v.user = current_user if respond_to?(:current_user) and v.respond_to?(:user=)
        end
      end
    end
  end
end