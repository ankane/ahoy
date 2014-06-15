module Ahoy
  module Extractors
    class TrafficSourceExtractor

      def initialize(referrer)
        @referrer = referrer
      end

      def referring_domain
        @referring_domain ||= Addressable::URI.parse(@referrer).host.first(255) rescue nil
      end

      def search_keyword
        @search_keyword ||= (self.class.referrer_parser.parse(@referrer)[1].first(255) rescue nil).presence
      end

      # performance hack for referer-parser
      def self.referrer_parser
        @referrer_parser ||= RefererParser::Referer.new("https://github.com/ankane/ahoy")
      end

    end
  end
end
