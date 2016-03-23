module Ahoy
  module Stores
    class BaseStore
      def initialize(options)
        @options = options
      end

      def track_visit(options)
      end

      def track_event(name, properties, options)
      end

      def visit
      end

      def authenticate(user)
        @user = user
        if visit && visit.respond_to?(:user) && !visit.user
          begin
            visit.user = user
            visit.save!
          rescue ActiveRecord::AssociationTypeMismatch
            # do nothing
          end
        end
      end

      def report_exception(e)
        raise e
      end

      def user
        @user ||= (controller.respond_to?(:current_user) && controller.current_user) || (controller.respond_to?(:current_resource_owner, true) && controller.send(:current_resource_owner)) || nil
      end

      def exclude?
        bot?
      end

      def generate_id
        SecureRandom.uuid
      end

      protected

      def bot?
        @bot ||= request ? Browser.new(request.user_agent).bot? : false
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

      def visit_properties
        ahoy.visit_properties
      end

      def set_visit_properties(visit)
        keys = visit_properties.keys
        keys.each do |key|
          visit.send(:"#{key}=", visit_properties[key]) if visit.respond_to?(:"#{key}=") && visit_properties[key]
        end
      end

      def geocode(visit)
        if Ahoy.geocode == :async
          Ahoy::GeocodeJob.set(queue: Ahoy.job_queue).perform_later(visit)
        end
      end

      def unique_exception_classes
        classes = []
        classes << ActiveRecord::RecordNotUnique if defined?(ActiveRecord::RecordNotUnique)
        classes << PG::UniqueViolation if defined?(PG::UniqueViolation)
        classes
      end
    end
  end
end
