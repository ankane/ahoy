module Ahoy
  module Deckhands
    class TrafficSourceDeckhand
      def initialize(referrer)
        @referrer = referrer
      end

      def referring_domain
        @referring_domain ||= Addressable::URI.parse(@referrer).host.first(255) rescue nil
      end

      def search_keyword
        @search_keyword ||= (self.class.referrer_parser.parse(@referrer)[:term][0..255] rescue nil).presence
      end

      # performance hack for referer-parser
      def self.referrer_parser
        @referrer_parser ||= RefererParser::Parser.new
      end
    end
  end
end
