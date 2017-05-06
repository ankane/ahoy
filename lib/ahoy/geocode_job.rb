module Ahoy
  class GeocodeJob < ActiveJob::Base
    queue_as :ahoy

    def perform(visit)
      visit = Visit.find( BSON::Binary.new( visit ,:uuid) )   if visit.is_a?(String)
      deckhand = Deckhands::LocationDeckhand.new(visit.ip)
      Ahoy::VisitProperties::LOCATION_KEYS.each do |key|
        visit.send(:"#{key}=", deckhand.send(key)) if visit.respond_to?(:"#{key}=")
      end
      visit.save!
    end
  end
end
