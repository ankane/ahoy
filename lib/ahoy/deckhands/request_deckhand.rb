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

      def screen_height
        request.params["screen_height"]
      end

      def screen_width
        request.params["screen_width"]
      end
    end
  end
end
