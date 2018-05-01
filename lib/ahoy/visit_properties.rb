require "ipaddr"
require "browser"
require "referer-parser"
require "user_agent_parser"

module Ahoy
  class VisitProperties
    attr_reader :request, :params, :referrer, :landing_page

    def initialize(request, api:)
      @request = request
      @params = request.params
      @referrer = api ? params["referrer"] : request.referer
      @landing_page = api ? params["landing_page"] : request.original_url
    end

    def generate
      @generate ||= request_properties.merge(tech_properties).merge(traffic_properties).merge(utm_properties)
    end

    private

    def utm_properties
      landing_uri = Addressable::URI.parse(landing_page) rescue nil
      landing_params = (landing_uri && landing_uri.query_values) || {}

      props = {}
      %w(utm_source utm_medium utm_term utm_content utm_campaign).each do |name|
        props[name.to_sym] = params[name] || landing_params[name]
      end
      props
    end

    def traffic_properties
      # cache for performance
      @@referrer_parser ||= RefererParser::Parser.new

      {
        referring_domain: (Addressable::URI.parse(referrer).host.first(255) rescue nil),
        search_keyword: (@@referrer_parser.parse(@referrer)[:term].first(255) rescue nil).presence
      }
    end

    def tech_properties
      # cache for performance
      @@user_agent_parser ||= UserAgentParser::Parser.new

      user_agent = request.user_agent
      agent = @@user_agent_parser.parse(user_agent)
      browser = Browser.new(user_agent)
      device_type =
        if browser.bot?
          "Bot"
        elsif browser.device.tv?
          "TV"
        elsif browser.device.console?
          "Console"
        elsif browser.device.tablet?
          "Tablet"
        elsif browser.device.mobile?
          "Mobile"
        else
          "Desktop"
        end

      {
        browser: agent.name,
        os: agent.os.name,
        device_type: device_type,
      }
    end

    # masking based on Google Analytics anonymization
    # https://support.google.com/analytics/answer/2763052
    def ip
      ip = request.remote_ip
      if ip && Ahoy.mask_ip
        addr = IPAddr.new(ip)
        if addr.ipv4?
          # set last octet to 0
          addr.mask(24).to_s
        else
          # set last 80 bits to zeros
          addr.mask(48).to_s
        end
      else
        ip
      end
    end

    def request_properties
      {
        ip: ip,
        user_agent: ensure_utf8(request.user_agent),
        referrer: referrer,
        landing_page: landing_page,
        platform: params["platform"],
        app_version: params["app_version"],
        os_version: params["os_version"],
        screen_height: params["screen_height"],
        screen_width: params["screen_width"]
      }
    end

    def ensure_utf8(str)
      if str
        str.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "")
      end
    end
  end
end
