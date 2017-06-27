module Ahoy
  class CookieJar
    def initialize(cookies)
      @cookies = cookies
    end

    def set_cookie(name, value, duration = nil, use_domain = true)
      cookie = {
        value: value
      }
      cookie[:expires] = duration.from_now if duration
      cookie[:secure] = true if Ahoy.secure_cookies
      domain = Ahoy.cookie_domain || Ahoy.domain
      cookie[:domain] = domain if domain && use_domain
      @cookies[name] = cookie
    end

    protected

    attr_reader :cookies
  end
end
