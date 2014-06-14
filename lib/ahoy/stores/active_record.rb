module Ahoy
  module Stores
    class ActiveRecord

      def track_event(name, properties, options)
        subscribers = Ahoy.subscribers
        if subscribers.any?
          subscribers.each do |subscriber|
            subscriber.track(name, properties, options)
          end
        else
          $stderr.puts "No subscribers"
        end
      end

      # TODO much better interface
      def track_visit(ahoy)
        request = ahoy.request
        params = ahoy.controller.params

        visit =
          Ahoy.visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.ip = request.remote_ip if v.respond_to?(:ip=)
            v.user_agent = request.user_agent if v.respond_to?(:user_agent=)
            v.referrer = params[:referrer] if v.respond_to?(:referrer=)
            v.landing_page = params[:landing_page] if v.respond_to?(:landing_page=)
            v.user = ahoy.user if v.respond_to?(:user=)
            v.platform = params[:platform] if v.respond_to?(:platform=)
            v.app_version = params[:app_version] if v.respond_to?(:app_version=)
            v.os_version = params[:os_version] if v.respond_to?(:os_version=)
          end

        begin
          visit.save!
        rescue ActiveRecord::RecordNotUnique
          # do nothing
        end
      end

      def current_visit(ahoy)
        Ahoy.visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
      end

    end
  end
end
