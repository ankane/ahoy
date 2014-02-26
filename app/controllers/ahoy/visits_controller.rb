module Ahoy
  class VisitsController < ActionController::Base
    before_filter :halt_bots

    def create
      visit =
        Ahoy::Visit.new do |v|
          v.visit_token = params[:visit_token]
          v.visitor_token = params[:visitor_token]
          v.ip = request.remote_ip
          v.user_agent = request.user_agent
          v.referrer = params[:referrer]
          v.landing_page = params[:landing_page]
          v.user = current_user if respond_to?(:current_user)
        end

      referring_uri = Addressable::URI.parse(params[:referrer]) rescue nil
      if referring_uri
        visit.referring_domain = referring_uri.host
      end

      landing_uri = Addressable::URI.parse(params[:landing_page]) rescue nil
      if landing_uri
        visit.campaign = (landing_uri.query_values || {})["utm_campaign"]
      end

      visit.browser = browser.name

      # TODO add more
      visit.os =
        if browser.android?
          "Android"
        elsif browser.ios?
          "iOS"
        elsif browser.windows_phone?
          "Windows Phone"
        elsif browser.blackberry?
          "Blackberry"
        elsif browser.chrome_os?
          "Chrome OS"
        elsif browser.mac?
          "Mac"
        elsif browser.windows?
          "Windows"
        elsif browser.linux?
          "Linux"
        end

      visit.device_type =
        if browser.tv?
          "TV"
        elsif browser.console?
          "Console"
        elsif browser.tablet?
          "Tablet"
        elsif browser.mobile?
          "Mobile"
        else
          "Desktop"
        end

      # location
      location = Geocoder.search(request.remote_ip).first rescue nil
      if location
        visit.country = location.country.presence
        visit.region = location.state.presence
        visit.city = location.city.presence
      end

      visit.save!
      render json: {id: visit.id}
    end

    protected

    def browser
      @browser ||= Browser.new(ua: request.user_agent)
    end

    def halt_bots
      if browser.bot?
        render json: {}
      end
    end

  end
end
