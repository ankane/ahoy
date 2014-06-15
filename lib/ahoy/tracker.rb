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

        options[:time] ||= trusted_time(options)
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

      unless exclude?
        options = options.dup

        options[:time] ||= trusted_time(options)

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
      @visit_token ||= existing_visit_token || generate_id
    end

    def visitor_token
      @visitor_token ||= existing_visitor_token || generate_id
    end

    def set_visit_cookie
      if !existing_visit_token
        cookie = {
          value: visit_token,
          expires: 4.hours.from_now
        }
        cookie[:domain] = Ahoy.domain if Ahoy.domain
        controller.response.set_cookie(:ahoy_visit, cookie)
      end
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

    def extractor
      @extractor ||= Ahoy::Extractor.new(request)
    end

    protected

    def trusted_time(options)
      if options[:time] and options[:trusted] == false and (1.minute.ago..Time.now).cover?(options[:time])
        options[:time]
      else
        Time.zone.now
      end
    end

    def exclude?
      @store.exclude?
    end

    def report_exception(e)
      @store.report_exception(e)
      if Rails.env.development?
        raise e
      end
    end

    def generate_id
      @store.generate_id
    end

    def existing_visit_token
      @existing_visit_token ||= request.headers["Ahoy-Visit"] || request.cookies["ahoy_visit"] || current_visit.try(:visit_token)
    end

    def existing_visitor_token
      @existing_visitor_token ||= request.headers["Ahoy-Visitor"] || request.cookies["ahoy_visitor"] || current_visit.try(:visitor_token)
    end

  end
end
