module Ahoy
  class RequestTracker < Tracker
    def initialize(request, **options)
      super(
        params: {
          "remote_ip" => request.remote_ip,
          "user_agent" => request.user_agent,
          "referrer" => request.referer,
          "landing_page" => request.original_url
        }.merge(request.params),
        headers: request.headers,
        cookies: request.cookies,
        cookie_jar: request.cookie_jar,
        **options
      )
    end
  end
end
