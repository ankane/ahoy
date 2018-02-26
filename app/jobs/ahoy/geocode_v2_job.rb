module Ahoy
  class GeocodeV2Job < ActiveJob::Base
    queue_as { Ahoy.job_queue }

    def perform(visit_token, ip)
      location =
        begin
          Geocoder.search(ip).first
        rescue => e
          $stderr.puts e.message
          nil
        end

      if location
        data = {
          visit_token: visit_token,
          country: location.try(:country).presence,
          region: location.try(:state).presence,
          city: location.try(:city).presence,
          postal_code: location.try(:postal_code).presence,
          latitude: location.try(:latitude).presence,
          longitude: location.try(:longitude).presence
        }

        Ahoy::Tracker.new(visit_token: visit_token).geocode(data)
      end
    end
  end
end
