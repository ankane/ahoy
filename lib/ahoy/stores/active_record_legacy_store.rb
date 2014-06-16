module Ahoy
  module Stores
    class ActiveRecordLegacyStore < BaseStore

      def track_visit(options, &block)
        visit =
          visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.user = user if v.respond_to?(:user=)
            v.created_at = options[:time]
          end

        ahoy.extractor.keys.each do |key|
          visit.send(:"#{key}=", ahoy.extractor.send(key)) if visit.respond_to?(:"#{key}=")
        end

        yield(visit) if block_given?

        begin
          visit.save!
        rescue ActiveRecord::RecordNotUnique
          # do nothing
        end
      end

      def track_event(name, properties, options, &block)
        event =
          event_model.new do |e|
            e.visit_id = current_visit.try(:id)
            e.user = user
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end

        yield(event) if block_given?

        event.save!

        options[:controller] ||= controller
        options[:user] ||= user
        options[:visit] ||= current_visit
        options[:visit_token] ||= ahoy.visit_token
        options[:visitor_token] ||= ahoy.visitor_token

        subscribers = Ahoy.subscribers
        if subscribers.any?
          warn "[DEPRECATION] Ahoy.subscribers is deprecated"
          subscribers.each do |subscriber|
            subscriber.track(name, properties, options.dup)
          end
        else
          $stderr.puts "No subscribers"
        end
      end

      def current_visit
        visit_model.where(id: ahoy.visit_token).first if ahoy.visit_token
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
        user_method = Ahoy.user_method
        if user_method.respond_to?(:call)
          user_method.call(controller)
        else
          controller.send(user_method)
        end
      end

      protected

      def visit_model
        ::Visit
      end

      def event_model
        ::Ahoy::Event
      end

    end
  end
end
