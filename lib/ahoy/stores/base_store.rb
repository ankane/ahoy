module Ahoy
  module Stores
    class BaseStore

      def initialize(options = {})
        @options = options
      end

      def track_visit(options)
      end

      def track_event(name, properties, options)
      end

      def current_visit
      end

      def authenticate(user)
        if current_visit and current_visit.respond_to?(:user) and !current_visit.user
          current_visit.user = current_user
          current_visit.save!
        end
      end

      def report_exception(e)
      end

      def user
        controller.current_user
      end

      def exclude?
        bot?
      end

      def generate_id
        SecureRandom.uuid
      end

      protected

      def bot?
        @bot ||= Browser.new(ua: request.user_agent).bot?
      end

      def request
        @request ||= @options[:request] || controller.try(:request)
      end

      def controller
        @controller ||= @options[:controller]
      end

      def ahoy
        @ahoy ||= @options[:ahoy]
      end

    end
  end
end
