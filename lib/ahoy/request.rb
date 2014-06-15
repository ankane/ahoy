module Ahoy
  class Request
    attr_reader :request

    TRAFFIC_SOURCE_KEYS = [:referring_domain, :search_keyword]
    UTM_PARAMETERS_KEYS = [:utm_source, :utm_medium, :utm_term, :utm_content, :utm_campaign]
    TECHNOLOGY_KEYS = [:browser, :os, :device_type]
    LOCATION_KEYS = [:country, :region, :city]

    KEYS = [:ip, :user_agent, :referrer, :landing_page, :platform, :app_version, :os_version] +
      TRAFFIC_SOURCE_KEYS + UTM_PARAMETERS_KEYS + TECHNOLOGY_KEYS + LOCATION_KEYS

    delegate *TRAFFIC_SOURCE_KEYS, to: :traffic_source_extractor
    delegate *UTM_PARAMETERS_KEYS, to: :utm_parameters_extractor
    delegate *TECHNOLOGY_KEYS, to: :technology_extractor
    delegate *LOCATION_KEYS, to: :location_extractor

    def initialize(request)
      @request = request
    end

    def attributes
      @attributes ||= KEYS.inject({}){|memo, key| memo[key] = send(key); memo }
    end

    def ip
      request.remote_ip
    end

    def user_agent
      request.user_agent
    end

    def referrer
      request.params["referrer"]
    end

    def landing_page
      request.params["landing_page"]
    end

    def platform
      request.params["platform"]
    end

    def app_version
      request.params["app_version"]
    end

    def os_version
      request.params["os_version"]
    end

    protected

    def traffic_source_extractor
      @traffic_source_extractor ||= Extractors::TrafficSource.new(referrer)
    end

    def utm_parameters_extractor
      @utm_parameters_extractor ||= Extractors::UtmParameters.new(landing_page)
    end

    def technology_extractor
      @technology_extractor ||= Extractors::Technology.new(user_agent)
    end

    def location_extractor
      @location_extractor ||= Extractors::Location.new(ip)
    end

  end
end
