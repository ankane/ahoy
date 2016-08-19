module Ahoy
  class VisitProperties
    REQUEST_KEYS = [:ip, :user_agent, :referrer, :landing_page, :platform, :app_version, :os_version, :screen_height, :screen_width]
    TRAFFIC_SOURCE_KEYS = [:referring_domain, :search_keyword]
    UTM_PARAMETER_KEYS = [:utm_source, :utm_medium, :utm_term, :utm_content, :utm_campaign]
    TECHNOLOGY_KEYS = [:browser, :os, :device_type]
    LOCATION_KEYS = [:country, :region, :city, :postal_code, :latitude, :longitude]

    KEYS = REQUEST_KEYS + TRAFFIC_SOURCE_KEYS + UTM_PARAMETER_KEYS + TECHNOLOGY_KEYS + LOCATION_KEYS

    delegate(*REQUEST_KEYS, to: :request_deckhand)
    delegate(*TRAFFIC_SOURCE_KEYS, to: :traffic_source_deckhand)
    delegate(*(UTM_PARAMETER_KEYS + [:landing_params]), to: :utm_parameter_deckhand)
    delegate(*TECHNOLOGY_KEYS, to: :technology_deckhand)
    delegate(*LOCATION_KEYS, to: :location_deckhand)

    def initialize(request, options = {})
      @request = request
      @options = options
    end

    def [](key)
      send(key)
    end

    def keys
      if Ahoy.geocode == true # no location keys for :async
        KEYS
      else
        KEYS - LOCATION_KEYS
      end
    end

    def to_hash
      keys.inject({}) { |memo, key| memo[key] = send(key); memo }
    end

    protected

    def request_deckhand
      @request_deckhand ||= Deckhands::RequestDeckhand.new(@request, @options)
    end

    def traffic_source_deckhand
      @traffic_source_deckhand ||= Deckhands::TrafficSourceDeckhand.new(request_deckhand.referrer)
    end

    def utm_parameter_deckhand
      @utm_parameter_deckhand ||= Deckhands::UtmParameterDeckhand.new(request_deckhand.landing_page)
    end

    def technology_deckhand
      @technology_deckhand ||= Deckhands::TechnologyDeckhand.new(request_deckhand.user_agent)
    end

    def location_deckhand
      @location_deckhand ||= Deckhands::LocationDeckhand.new(request_deckhand.ip)
    end
  end
end
