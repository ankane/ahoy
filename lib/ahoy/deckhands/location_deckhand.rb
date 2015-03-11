module Ahoy
  module Deckhands
    class LocationDeckhand
      def initialize(ip)
        @ip = ip
      end

      def country
        location.try(:country).presence
      end

      def region
        location.try(:state).presence
      end

      def postal_code
        location.try(:postal_code).presence
      end

      def city
        location.try(:city).presence
      end

      def latitude
        location.try(:latitude).presence
      end

      def longitude
        location.try(:longitude).presence
      end

      protected

      def location
        unless @checked
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
