module Ahoy
  class EventsController < Ahoy::BaseController

    def create
      events = params[:name] ? [params] : ActiveSupport::JSON.decode(request.body.read)
      events.each do |event|
        time = Time.zone.parse(event["time"]) rescue nil

        # timestamp is deprecated
        time ||= Time.zone.at(event["time"].to_f) rescue nil

        options = {
          id: event["id"],
          time: time,
          trusted: false
        }
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end

  end
end
