module Ahoy
  class Tracker
    attr_reader :request, :controller

    def initialize(options = {})
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
    end

    def track(name, properties = {}, options = {})
      if track?
        # publish to each subscriber
        options = options.dup
        if @controller
          options[:controller] ||= @controller
          options[:user] ||= Ahoy.fetch_user(@controller)
        end

        options[:visit] ||= current_visit
        options[:visit_token] ||= visit_token
        options[:visitor_token] ||= visitor_token
        options[:time] ||= Time.zone.now
        options[:id] ||= Ahoy.generate_id

        subscribers = Ahoy.subscribers
        if subscribers.any?
          subscribers.each do |subscriber|
            subscriber.track(name, properties, options)
          end
        else
          $stderr.puts "No subscribers"
        end
      end

      true
    end

    # not a public API - do not use
    def track_visit
      visit_token = params[:visit_token] || Ahoy.generate_id
      visitor_token = params[:visitor_token] || Ahoy.generate_id

      if track?
        # TODO move to subscriber
        visit =
          Ahoy.visit_model.new do |v|
            v.visit_token = visit_token
            v.visitor_token = visitor_token
            v.ip = request.remote_ip if v.respond_to?(:ip=)
            v.user_agent = request.user_agent if v.respond_to?(:user_agent=)
            v.referrer = params[:referrer] if v.respond_to?(:referrer=)
            v.landing_page = params[:landing_page] if v.respond_to?(:landing_page=)
            v.user = Ahoy.fetch_user(@controller) if v.respond_to?(:user=)
            v.platform = params[:platform] if v.respond_to?(:platform=)
            v.app_version = params[:app_version] if v.respond_to?(:app_version=)
            v.os_version = params[:os_version] if v.respond_to?(:os_version=)
          end

        begin
          visit.save!
        rescue ActiveRecord::RecordNotUnique
          # do nothing
        end
      end

      {visit_token: visit_token, visitor_token: visitor_token}
    end

    # TODO move to subscriber
    def current_visit
      @current_visit ||= Ahoy.visit_model.where(visit_token: visit_token).first if visit_token
    end

    def visit_token
      @visit_token ||= request.headers["Ahoy-Visit"] || request.cookies["ahoy_visit"]
    end

    def visitor_token
      @visitor_token ||= existing_visitor_token || current_visit.try(:visitor_token) || Ahoy.generate_id
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

    protected

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

    def params
      @controller.params
    end

  end
end
