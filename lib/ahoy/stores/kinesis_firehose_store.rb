module Ahoy
  module Stores
    class KinesisFirehoseStore < LogStore
      def log_visit(data)
        post(visits_stream, data)
      end

      def log_event(data)
        post(events_stream, data)
      end

      def client
        @client ||= Aws::Firehose::Client.new(credentials)
      end

      def post(stream, data)
        client.put_record(
          delivery_stream_name: stream,
          record: {
            data: "#{data.to_json}\n"
          }
        )
      end

      def credentials
        {
          access_key_id: ENV["AWS_ACCESS_KEY_ID"],
          secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
          region: "us-east-1"
        }
      end

      def visits_stream
        "ahoy_visits"
      end

      def events_stream
        "ahoy_events"
      end
    end
  end
end
