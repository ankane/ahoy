module Ahoy
  module Extractors
    class Location

      def initialize(ip)
        @ip = ip
      end

      def country
        location.try(:country).presence
      end

      def region
        location.try(:state).presence
      end

      def city
        location.try(:city).presence
      end

      protected

      def location
        if !@checked
          @location =
            begin
              Geocoder.search(@ip).first
            rescue => e
              $stderr.puts e.message
              nil
            end
          @checked = true
        end
        @location
      end

    end
  end
end
