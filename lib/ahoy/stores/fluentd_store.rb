module Ahoy
  module Stores
    class FluentdStore < LogStore
      def log_visit(data)
        logger.post("visit", data)
      end

      def log_event(data)
        logger.post("event", data)
      end

      def logger
        @logger ||= Fluent::Logger::FluentLogger.new("ahoy", host: ENV["FLUENTD_HOST"] || "localhost", port: ENV["FLUENTD_PORT"] || 24224)
      end
    end
  end
end
