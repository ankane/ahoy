module Ahoy
  class Tracker
    attr_reader :request, :controller

    def initialize(options = {})
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
    end

    def track(name, properties = {}, options = {})
      if track?
        options = options.dup

        options[:visit] ||= current_visit
        options[:visit_token] ||= visit_token
        options[:visitor_token] ||= visitor_token
        options[:user] ||= user
        options[:time] ||= Time.zone.now
        options[:id] ||= generate_id
        options[:controller] ||= @controller

        Ahoy.store.track_event(name, properties, options)
      end

      true
    end

    def track_visit
      @visit_token = request.params["visit_token"] || generate_id
      @visitor_token = request.params["visitor_token"] || generate_id

      if track?
        Ahoy.store.track_visit(self)
      end

      {visit_token: visit_token, visitor_token: visitor_token}
    end

    def current_visit
      @current_visit ||= Ahoy.store.current_visit(self)
    end

    def visit_token
      @visit_token ||= request.headers["Ahoy-Visit"] || request.cookies["ahoy_visit"]
    end

    def visitor_token
      @visitor_token ||= existing_visitor_token || current_visit.try(:visitor_token) || generate_id
    end

    def set_visitor_cookie
      if !existing_visitor_token
        cookie = {
          value: visitor_token,
          expires: 2.years.from_now
        }
        cookie[:domain] = Ahoy.domain if Ahoy.domain
        controller.response.set_cookie(:ahoy_visitor, cookie)
      end
    end

    def user
      @user ||= begin
        user_method = Ahoy.user_method
        if user_method.respond_to?(:call)
          user_method.call(controller)
        else
          controller.send(user_method)
        end
      end
    end

    # TODO better method
    def ahoy_request
      @ahoy_request ||= Ahoy::Request.new(request)
    end

    protected

    def generate_id
      SecureRandom.uuid
    end

    def existing_visitor_token
      request.headers["Ahoy-Visitor"] || request.cookies["ahoy_visitor"]
    end

    def track?
      (Ahoy.track_bots || !bot?) && !exclude?
    end

    def bot?
      @bot ||= Browser.new(ua: @request.user_agent).bot?
    end

    def exclude?
      if Ahoy.exclude_method
        if Ahoy.exclude_method.arity == 1
          Ahoy.exclude_method.call(@controller)
        else
          Ahoy.exclude_method.call(@controller, @request)
        end
      else
        false
      end
    end

  end
end
