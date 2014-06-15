module Ahoy
  module Extractors
    class TrafficSource

      def initialize(referrer)
        @referrer = referrer
      end

      def referring_domain
        @referring_domain ||= Addressable::URI.parse(@referrer).host.first(255) rescue nil
      end

      def search_keyword
        @search_keyword ||= (Ahoy.referrer_parser.parse(@referrer)[1].first(255) rescue nil).presence
      end

    end
  end
end
