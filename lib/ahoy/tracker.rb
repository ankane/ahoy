module Ahoy
  class Tracker
    attr_reader :request, :controller

    def initialize(**options)
      @store = Ahoy::Store.new(options.merge(ahoy: self))
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
      @visit_token = options[:visit_token]
      @options = options
    end

    # can't use keyword arguments here
    def track(name, properties = {}, options = {})
      if exclude?
        debug "Event excluded"
      elsif missing_params?
        debug "Missing required parameters"
      else
        data = {
          visit_token: visit_token,
          user_id: user.try(:id),
          name: name.to_s,
          properties: properties,
          time: trusted_time(options[:time]),
          event_id: options[:id] || generate_id
        }.select { |_, v| v }

        @store.track_event(data)
      end
      true
    rescue => e
      report_exception(e)
    end

    def track_visit(defer: false)
      if exclude?
        debug "Visit excluded"
      elsif missing_params?
        debug "Missing required parameters"
      else
        if defer
          set_cookie("ahoy_track", true, nil, false)
        else
          data = {
            visit_token: visit_token,
            visitor_token: visitor_token,
            user_id: user.try(:id),
            started_at: trusted_time,
          }.merge(visit_properties).select { |_, v| v }

          @store.track_visit(data)

          Ahoy::GeocodeV2Job.perform_later(visit_token, data[:ip]) if Ahoy.geocode
        end
      end
      true
    rescue => e
      report_exception(e)
    end

    def geocode(data)
      if exclude?
        debug "Geocode excluded"
      else
        @store.geocode(data.select { |_, v| v })
        true
      end
    rescue => e
      report_exception(e)
    end

    def authenticate(user)
      if exclude?
        debug "Authentication excluded"
      else
        @store.user = user

        data = {
          visit_token: visit_token,
          user_id: user.try(:id)
        }
        @store.authenticate(data)
      end
      true
    rescue => e
      report_exception(e)
    end

    def visit
      @visit ||= @store.visit
    end

    def new_visit?
      !existing_visit_token
    end

    def new_visitor?
      !existing_visitor_token
    end

    def set_visit_cookie
      set_cookie("ahoy_visit", visit_token, Ahoy.visit_duration)
    end

    def set_visitor_cookie
      if new_visitor?
        set_cookie("ahoy_visitor", visitor_token, Ahoy.visitor_duration)
      end
    end

    def user
      @user ||= @store.user
    end

    # TODO better name
    def visit_properties
      @visit_properties ||= Ahoy::VisitProperties.new(request, api: api?).generate
    end

    def visit_token
      @visit_token ||= ensure_token(visit_token_helper)
    end
    alias_method :visit_id, :visit_token

    def visitor_token
      @visitor_token ||= ensure_token(visitor_token_helper)
    end
    alias_method :visitor_id, :visitor_token

    def reset
      reset_visit
      request.cookie_jar.delete("ahoy_visitor")
    end

    def reset_visit
      request.cookie_jar.delete("ahoy_visit")
      request.cookie_jar.delete("ahoy_events")
      request.cookie_jar.delete("ahoy_track")
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
      domain = Ahoy.cookie_domain
      cookie[:domain] = domain if domain && use_domain
      request.cookie_jar[name] = cookie
    end

    def trusted_time(time = nil)
      if !time || (api? && !(1.minute.ago..Time.now).cover?(time))
        Time.zone.now
      else
        time
      end
    end

    def exclude?
      @store.exclude?
    end

    def report_exception(e)
      Safely.report_exception(e)
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

    def ensure_token(token)
      token.to_s.gsub(/[^a-z0-9\-]/i, "").first(64) if token
    end

    def debug(message)
      Rails.logger.debug { "[ahoy] #{message}" }
    end
  end
end
