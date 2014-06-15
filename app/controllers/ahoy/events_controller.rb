module Ahoy
  class EventsController < Ahoy::BaseController

    def create
      events = params[:name] ? [params] : ActiveSupport::JSON.decode(request.body.read)
      events.each do |event|
        options = {
          id: event["id"],
          time: (Time.zone.at(event["time"].to_f) rescue nil),
          trusted: false
        }
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end

  end
end
