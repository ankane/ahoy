require "cgi"
require "device_detector"
require "uri"

module Ahoy
  class VisitProperties
    attr_reader :params, :referrer, :landing_page, :user_agent, :remote_ip

    def initialize(params, api:)
      @params = params
      @referrer = params["referrer"]
      @landing_page = params["landing_page"]
      @user_agent = params["user_agent"]
      @remote_ip = params["remote_ip"]
    end

    def generate
      @generate ||= request_properties.merge(tech_properties).merge(traffic_properties).merge(utm_properties)
    end

    private

    def utm_properties
      landing_params = {}
      begin
        landing_uri = URI.parse(landing_page)
        # could also use Rack::Utils.parse_nested_query
        landing_params = CGI.parse(landing_uri.query) if landing_uri
      rescue
        # do nothing
      end

      %w(utm_source utm_medium utm_term utm_content utm_campaign).each_with_object({}) do |name, props|
        props[name.to_sym] = params[name] || landing_params[name].try(:first)
      end
    end

    def traffic_properties
      uri = URI.parse(referrer) rescue nil
      {
        referring_domain: uri.try(:host).try(:first, 255)
      }
    end

    def tech_properties
      if Ahoy.user_agent_parser == :device_detector
        client = DeviceDetector.new(user_agent)
        device_type =
          case client.device_type
          when "smartphone"
            "Mobile"
          when "tv"
            "TV"
          else
            client.device_type.try(:titleize)
          end

        {
          browser: client.name,
          os: client.os_name,
          device_type: device_type
        }
      else
        raise "Add browser to your Gemfile to use legacy user agent parsing" unless defined?(Browser)
        raise "Add user_agent_parser to your Gemfile to use legacy user agent parsing" unless defined?(UserAgentParser)

        # cache for performance
        @@user_agent_parser ||= UserAgentParser::Parser.new

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
          device_type: device_type
        }
      end
    end

    # masking based on Google Analytics anonymization
    # https://support.google.com/analytics/answer/2763052
    def ip
      if remote_ip && Ahoy.mask_ips
        Ahoy.mask_ip(remote_ip)
      else
        remote_ip
      end
    end

    def request_properties
      {
        ip: ip,
        user_agent: Ahoy::Utils.ensure_utf8(user_agent),
        referrer: referrer,
        landing_page: landing_page,
        platform: params["platform"],
        app_version: params["app_version"],
        os_version: params["os_version"],
        screen_height: params["screen_height"],
        screen_width: params["screen_width"]
      }
    end
  end
end
