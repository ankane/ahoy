module Ahoy
  module Stores
    class ActiveRecordStore < BaseStore

      def track_visit(options, &block)
        visit =
          visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.user = user if v.respond_to?(:user=)
            v.created_at = options[:time]
          end

        Ahoy::Request::KEYS.each do |key|
          visit.send(:"#{key}=", ahoy.ahoy_request.send(key)) if visit.respond_to?(:"#{key}=")
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
            e.visit = current_visit
            e.user = user
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end

        yield(event) if block_given?

        event.save!
      end

      def current_visit
        visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
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
