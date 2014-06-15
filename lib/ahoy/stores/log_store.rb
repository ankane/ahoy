module Ahoy
  module Stores
    class LogStore < BaseStore

      def track_visit(options, &block)
        data = {
          id: ahoy.visit_id,
          visitor_id: ahoy.visitor_id,
        }.merge(ahoy.extractor.attributes)
        data[:user_id] = user.id if user
        data[:started_at] = options[:started_at]

        yield(data) if block_given?

        visit_logger.info data.to_json
      end

      def track_event(name, properties, options, &block)
        data = {
          id: options[:id],
          name: name,
          properties: properties,
          visit_id: ahoy.visit_id,
          visitor_id: ahoy.visitor_id
        }
        data[:user_id] = user.id if user
        data[:time] = options[:time]

        yield(data) if block_given?

        event_logger.info data.to_json
      end

      protected

      # TODO disable header
      def visit_logger
        @visit_logger ||= ActiveSupport::Logger.new(Rails.root.join("log/visits.log"))
      end

      def event_logger
        @event_logger ||= ActiveSupport::Logger.new(Rails.root.join("log/events.log"))
      end

    end
  end
end
