module Ahoy
  module Stores
    class Log

      def track_event(name, properties, options)
        data = {
          name: name,
          properties: properties
        }.merge(options.slice(:time, :id, :visit_token, :visitor_token))
        data[:user_id] = options[:user].id if options[:user]
        event_logger.info data.to_json
      end

      # TODO much better interface
      def track_visit(ahoy)
        data = {
          visit_token: ahoy.visit_token,
          visitor_token: ahoy.visitor_token,
          time: Time.zone.now
        }.merge(ahoy.ahoy_request.attributes)
        visit_logger.info data.to_json
      end

      def current_visit(ahoy)
        nil # not queryable
      end

      protected

      # TODO disable header
      def event_logger
        ActiveSupport::Logger.new(Rails.root.join("log/events.log"))
      end

      def visit_logger
        ActiveSupport::Logger.new(Rails.root.join("log/visits.log"))
      end

    end
  end
end
