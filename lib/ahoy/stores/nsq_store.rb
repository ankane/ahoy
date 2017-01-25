module Ahoy
  module Stores
    class NsqStore < LogStore
      def log_visit(data)
        post(visits_topic, data)
      end

      def log_event(data)
        post(events_topic, data)
      end

      def client
        @client ||= begin
          require "nsq"
          client = Nsq::Producer.new(
            nsqd: ENV["NSQ_URL"] || "127.0.0.1:4150"
          )
          at_exit { client.terminate }
          client
        end
      end

      def post(topic, data)
        client.write_to_topic(topic, data.to_json)
      end

      def visits_topic
        "ahoy_visits"
      end

      def events_topic
        "ahoy_events"
      end
    end
  end
end
