module Ahoy
  class EventsController < Ahoy::BaseController
    def create
      events =
        if params[:name]
          # legacy API
          [request.params]
        elsif params[:events]
          request.params[:events]
        else
          begin
            ActiveSupport::JSON.decode(request.body.read)
          rescue ActiveSupport::JSON.parse_error
            # do nothing
            []
          end
        end

      events.first(Ahoy.max_events_per_request).each do |event|
        time = Time.zone.parse(event["time"]) rescue nil

        # timestamp is deprecated
        time ||= Time.zone.at(event["time"].to_f) rescue nil

        options = {
          id: event["id"],
          time: time
        }
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end
  end
end
