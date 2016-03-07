require "rack/attack"

module Ahoy
  class Throttle < Rack::Attack
    throttle("ahoy/ip", limit: Ahoy.throttle_limit, period: Ahoy.throttle_period) do |req|
      if req.path.start_with?("/ahoy/")
        req.ip
      end
    end

    def_delegators self, :whitelisted?, :blacklisted?, :throttled?, :tracked?

    def self.throttled_response
      Rack::Attack.throttled_response
    end
  end
end
