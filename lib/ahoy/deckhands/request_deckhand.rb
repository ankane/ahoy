module Ahoy
  module Deckhands
    class RequestDeckhand
      attr_reader :request

      def initialize(request, options = {})
        @request = request
        @options = options
      end

      def ip
        request.remote_ip
      end

      def user_agent
        request.user_agent
      end

      def referrer
        @options[:api] ? params["referrer"] : request.referer
      end

      def landing_page
        @options[:api] ? params["landing_page"] : request.original_url
      end

      def platform
        params["platform"]
      end

      def app_version
        params["app_version"]
      end

      def os_version
        params["os_version"]
      end

      def screen_height
        params["screen_height"]
      end

      def screen_width
        params["screen_width"]
      end

      def params
        @params ||= request.params
      end
    end
  end
end
