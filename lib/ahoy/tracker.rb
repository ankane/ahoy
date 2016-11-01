module Ahoy
  class Tracker
    attr_reader :request, :controller

    def initialize(options = {})
      @store = Ahoy::Store.new(options.merge(ahoy: self))
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
      @options = options
    end

    def track(name, properties = {}, options = {})
      if exclude?
        debug "Event excluded"
      elsif missing_params?
        debug "Missing required parameters"
      else
        options = options.dup

        options[:time] = trusted_time(options[:time])
        options[:id] = ensure_uuid(options[:id] || generate_id)

        @store.track_event(name, properties, options)
      end
      true
    rescue => e
      report_exception(e)
    end

    def track_visit(options = {})
      if exclude?
        debug "Visit excluded"
      elsif missing_params?
        debug "Missing required parameters"
      else
        if options[:defer]
          set_cookie("ahoy_track", true, nil, false)
        else
          options = options.dup

          options[:started_at] ||= Time.zone.now

          @store.track_visit(options)
        end
      end
      true
    rescue => e
      report_exception(e)
    end

    def authenticate(user)
      if exclude?
        debug "Authentication excluded"
      else
        @store.authenticate(user)
      end
      true
    rescue => e
      report_exception(e)
    end

    def visit
      @visit ||= @store.visit
    end

    def visit_id
      @visit_id ||= ensure_uuid(visit_token_helper)
    end

    def visitor_id
      @visitor_id ||= ensure_uuid(visitor_token_helper)
    end

    def new_visit?
      !existing_visit_token
    end

    def new_visitor?
      !existing_visitor_token
    end

    def set_visit_cookie
      set_cookie("ahoy_visit", visit_id, Ahoy.visit_duration)
    end

    def set_visitor_cookie
      if new_visitor?
        set_cookie("ahoy_visitor", visitor_id, Ahoy.visitor_duration)
      end
    end

    def user
      @user ||= @store.user
    end

    # TODO better name
    def visit_properties
      @visit_properties ||= Ahoy::VisitProperties.new(request, api: api?)
    end

    def visit_token
      @visit_token ||= ensure_token(visit_token_helper)
    end

    def visitor_token
      @visitor_token ||= ensure_token(visitor_token_helper)
    end

    protected

    def api?
      @options[:api]
    end

    def missing_params?
      if api? && Ahoy.protect_from_forgery
        !(existing_visit_token && existing_visitor_token)
      else
        false
      end
    end

    def set_cookie(name, value, duration = nil, use_domain = true)
      cookie = {
        value: value
      }
      cookie[:expires] = duration.from_now if duration
      domain = Ahoy.cookie_domain || Ahoy.domain
      cookie[:domain] = domain if domain && use_domain
      request.cookie_jar[name] = cookie
    end

    def trusted_time(time)
      if !time || (api? && !(1.minute.ago..Time.now).cover?(time))
        Time.zone.now
      else
        time
      end
    end

    def exclude?
      @store.exclude?
    end

    # odd pattern for backwards compatibility
    # TODO remove this method in next major release
    def report_exception(e)
      Safely.safely do
        @store.report_exception(e)
        if Rails.env.development? || Rails.env.test?
          raise e
        end
      end
    end

    def generate_id
      @store.generate_id
    end

    def visit_token_helper
      @visit_token_helper ||= begin
        token = existing_visit_token
        token ||= generate_id unless Ahoy.api_only
        token
      end
    end

    def visitor_token_helper
      @visitor_token_helper ||= begin
        token = existing_visitor_token
        token ||= generate_id unless Ahoy.api_only
        token
      end
    end

    def existing_visit_token
      @existing_visit_token ||= begin
        token = visit_header
        token ||= visit_cookie unless api? && Ahoy.protect_from_forgery
        token ||= visit_param if api?
        token
      end
    end

    def existing_visitor_token
      @existing_visitor_token ||= begin
        token = visitor_header
        token ||= visitor_cookie unless api? && Ahoy.protect_from_forgery
        token ||= visitor_param if api?
        token
      end
    end

    def visit_cookie
      @visit_cookie ||= request && request.cookies["ahoy_visit"]
    end

    def visitor_cookie
      @visitor_cookie ||= request && request.cookies["ahoy_visitor"]
    end

    def visit_header
      @visit_header ||= request && request.headers["Ahoy-Visit"]
    end

    def visitor_header
      @visitor_header ||= request && request.headers["Ahoy-Visitor"]
    end

    def visit_param
      @visit_param ||= request && request.params["visit_token"]
    end

    def visitor_param
      @visitor_param ||= request && request.params["visitor_token"]
    end

    def ensure_uuid(id)
      Ahoy.ensure_uuid(id) if id
    end

    def ensure_token(token)
      token.to_s.gsub(/[^a-z0-9\-]/i, "").first(64) if token
    end

    def debug(message)
      Rails.logger.debug { "[ahoy] #{message}" }
    end
  end
end
