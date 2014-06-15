module Ahoy
  module Stores
    class LogStore < BaseStore

      def track_visit(options = {}, &block)
        data = {
          visit_token: visit_token,
          visitor_token: visitor_token,
          time: Time.zone.now
        }.merge(ahoy.ahoy_request.attributes)

        yield(data) if block_given?

        visit_logger.info data.to_json
      end

      def track_event(name, properties, options)
        data = {
          name: name,
          properties: properties
        }.merge(options.slice(:time, :id, :visit_token, :visitor_token))

        data[:user_id] = options[:user].id if options[:user]

        yield(data) if block_given?

        event_logger.info data.to_json
      end

      protected

      # TODO disable header
      def visit_logger
        ActiveSupport::Logger.new(Rails.root.join("log/visits.log"))
      end

      def event_logger
        ActiveSupport::Logger.new(Rails.root.join("log/events.log"))
      end

    end
  end
end
