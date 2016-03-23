module Ahoy
  module Stores
    class ActiveRecordTokenStore < BaseStore
      def track_visit(options, &block)
        visit =
          visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.user = user if v.respond_to?(:user=)
            v.started_at = options[:started_at] if v.respond_to?(:started_at)
            v.created_at = options[:started_at] if v.respond_to?(:created_at)
          end

        set_visit_properties(visit)

        yield(visit) if block_given?

        begin
          visit.save!
          geocode(visit)
        rescue *unique_exception_classes
          # do nothing
        end
      end

      def track_event(name, properties, options, &block)
        if self.class.uses_deprecated_subscribers?
          options[:controller] ||= controller
          options[:user] ||= user
          options[:visit] ||= visit
          options[:visit_token] ||= ahoy.visit_token
          options[:visitor_token] ||= ahoy.visitor_token

          subscribers = Ahoy.subscribers
          if subscribers.any?
            subscribers.each do |subscriber|
              subscriber.track(name, properties, options.dup)
            end
          else
            $stderr.puts "No subscribers"
          end
        else
          event =
            event_model.new do |e|
              e.visit_id = visit.try(:id)
              e.user = user
              e.name = name
              e.properties = properties
              e.time = options[:time]
            end

          yield(event) if block_given?

          event.save!
        end
      end

      def visit
        @visit ||= visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
      end

      def exclude?
        (!Ahoy.track_bots && bot?) ||
          (
            if Ahoy.exclude_method
              warn "[DEPRECATION] Ahoy.exclude_method is deprecated - use exclude? instead"
              if Ahoy.exclude_method.arity == 1
                Ahoy.exclude_method.call(controller)
              else
                Ahoy.exclude_method.call(controller, request)
              end
            else
              false
            end
          )
      end

      def user
        @user ||= begin
          user_method = Ahoy.user_method
          if user_method.respond_to?(:call)
            user_method.call(controller)
          elsif user_method
            controller.send(user_method)
          else
            super
          end
        end
      end

      class << self
        def uses_deprecated_subscribers
          warn "[DEPRECATION] Ahoy subscribers are deprecated"
          @uses_deprecated_subscribers = true
        end

        def uses_deprecated_subscribers?
          @uses_deprecated_subscribers || false
        end
      end

      protected

      def visit_model
        Ahoy.visit_model || ::Visit
      end

      def event_model
        ::Ahoy::Event
      end
    end
  end
end
