module Ahoy
  class EventsController < Ahoy::BaseController

    def create
      events = params[:name] ? [params] : ActiveSupport::JSON.decode(request.body.read)
      events.each do |event|
        options = {}
        if event["time"] and (time = Time.at(event["time"].to_f) rescue nil) and (1.minute.ago..Time.now).cover?(time)
          options[:time] = time
        end
        if event["id"]
          options[:id] = event["id"]
        end
        ahoy.track event["name"], event["properties"], options
      end
      render json: {}
    end

  end
end
