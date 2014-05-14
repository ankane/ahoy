module Ahoy
  class EventsController < Ahoy::BaseController

    def create
      options = {}
      if params[:time] and (time = Time.at(params[:time].to_f) rescue nil) and (1.minute.ago..Time.now).cover?(time)
        options[:time] = time
      end
      ahoy.track params[:name], params[:properties], options
      render json: {}
    end

  end
end
