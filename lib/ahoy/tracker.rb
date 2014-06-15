module Ahoy
  class Tracker
    attr_reader :request, :controller

    def initialize(options = {})
      @store = Ahoy::Store.new(options.merge(ahoy: self))
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
    end

    def track(name, properties = {}, options = {})
      unless exclude?
        options = options.dup

        options[:time] ||= Time.zone.now
        options[:id] ||= generate_id

        @store.track_event(name, properties, options)
      end

      true
    rescue => e
      report_exception(e)
    end

    def track_visit(options = {})
      @visit_token = request.params["visit_token"] || generate_id
      @visitor_token = request.params["visitor_token"] || generate_id

      options[:time] ||= Time.zone.now

      unless exclude?
        @store.track_visit(options)
      end

      true
    rescue => e
      report_exception(e)
    end

    def authenticate(user)
      @store.authenticate(user)
    rescue => e
      report_exception(e)
    end

    def current_visit
      @current_visit ||= @store.current_visit
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
      @user ||= @store.user
    end

    # TODO better method
    def ahoy_request
      @ahoy_request ||= Ahoy::Request.new(request)
    end

    protected

    def exclude?
      @store.exclude?
    end

    def report_exception(e)
      @store.report_exception(e)
    end

    def generate_id
      @store.generate_id
    end

    def existing_visitor_token
      @existing_visitor_token ||= request.headers["Ahoy-Visitor"] || request.cookies["ahoy_visitor"]
    end

  end
end
