require "rack/attack"

module Ahoy
  class Throttle < Rack::Attack
    throttle("ahoy/ip", limit: Ahoy.throttle_limit, period: Ahoy.throttle_period) do |req|
      if req.path.start_with?("/ahoy/")
        req.ip
      end
    end

    def_delegators self, :whitelisted?, :blacklisted?, :throttled?, :tracked?, :blocklisted?, :safelisted?

    def self.throttled_response
      Rack::Attack.throttled_response
    end

    def self.blacklisted_response
      Rack::Attack.blacklisted_response
    end

    def self.blocklisted_response
      Rack::Attack.blocklisted_response
    end
  end
end
