module Ahoy
  module Stores
    class NatsStore < LogStore
      def log_visit(data)
        publish(visits_subject, data)
      end

      def log_event(data)
        publish(events_subject, data)
      end

      def publish(subject, data)
        client.publish(subject, data.to_json)
      end

      def client
        @client ||= begin
          require "nats/io/client"
          client = NATS::IO::Client.new
          client.connect(servers: (ENV["NATS_URL"] || "nats://127.0.0.1:4222").split(","))
          client
        end
      end

      def visits_subject
        "ahoy_visits"
      end

      def events_subject
        "ahoy_events"
      end
    end
  end
end
