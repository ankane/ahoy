module Ahoy
  class Extractor
    attr_reader :request

    TRAFFIC_SOURCE_KEYS = [:referring_domain, :search_keyword]
    UTM_PARAMETERS_KEYS = [:utm_source, :utm_medium, :utm_term, :utm_content, :utm_campaign]
    TECHNOLOGY_KEYS = [:browser, :os, :device_type]
    LOCATION_KEYS = [:country, :region, :city]

    KEYS = [:ip, :user_agent, :referrer, :landing_page, :platform, :app_version, :os_version] +
      TRAFFIC_SOURCE_KEYS + UTM_PARAMETERS_KEYS + TECHNOLOGY_KEYS + LOCATION_KEYS

    delegate *TRAFFIC_SOURCE_KEYS, to: :traffic_source_extractor
    delegate *(UTM_PARAMETERS_KEYS + [:landing_params]), to: :utm_parameter_extractor
    delegate *TECHNOLOGY_KEYS, to: :technology_extractor
    delegate *LOCATION_KEYS, to: :location_extractor

    def initialize(request, options = {})
      @request = request
      @options = options
    end

    def [](key)
      send(key)
    end

    def keys
      KEYS
    end

    def to_hash
      keys.inject({}){|memo, key| memo[key] = send(key); memo }
    end

    def ip
      request.remote_ip
    end

    def user_agent
      request.user_agent
    end

    def referrer
      @options[:api] ? request.params["referrer"] : request.referer
    end

    def landing_page
      @options[:api] ? request.params["landing_page"] : request.original_url
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
      @traffic_source_extractor ||= Extractors::TrafficSourceExtractor.new(referrer)
    end

    def utm_parameter_extractor
      @utm_parameters_extractor ||= Extractors::UtmParameterExtractor.new(landing_page)
    end

    def technology_extractor
      @technology_extractor ||= Extractors::TechnologyExtractor.new(user_agent)
    end

    def location_extractor
      @location_extractor ||= Extractors::LocationExtractor.new(ip)
    end

  end
end
