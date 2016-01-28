module Ahoy
  class EventsController < Ahoy::BaseController
    def create
      return render json: {} unless current_user.registered?

      events =
        if params[:name]
          # legacy API
          [params]
        else
          begin
            ActiveSupport::JSON.decode(request.body.read)
          rescue ActiveSupport::JSON.parse_error
            # do nothing
            []
          end
        end

      events.each do |event|
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
