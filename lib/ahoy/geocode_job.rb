module Ahoy
  class GeocodeJob < ActiveJob::Base
    queue_as :ahoy

    def perform(visit)
      Geocoder.new.geocode(visit)
    end

    def geocode(visit)
      perform_later(visit)
    end
  end
end
