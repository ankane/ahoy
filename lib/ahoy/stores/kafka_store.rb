module Ahoy
  module Stores
    class KafkaStore < LogStore
      def log_visit(data)
        post(visits_topic, data)
      end

      def log_event(data)
        post(events_topic, data)
      end

      def client
        @client ||= begin
          client = Kafka.new(
            seed_brokers: ENV["KAFKA_URL"],
            logger: Rails.logger
          )
          at_exit { client.shutdown }
          client
        end
      end

      def producer
        @producer ||= client.async_producer(delivery_interval: 3)
      end

      def post(topic, data)
        producer.produce(data.to_json, topic: topic)
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
