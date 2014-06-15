module Ahoy
  module Stores
    class MongoidStore < BaseStore

      def track_visit(options, &block)
        visit =
          visit_model.new do |v|
            v.id = binary(ahoy.visit_token)
            v.visitor_token = binary(ahoy.visitor_token)
            v.user = user if v.respond_to?(:user=) && user
            v.created_at = options[:time]
          end

        Ahoy::Request::KEYS.each do |key|
          visit.send(:"#{key}=", ahoy.ahoy_request.send(key)) if visit.respond_to?(:"#{key}=") && ahoy.ahoy_request.send(key)
        end

        yield(visit) if block_given?

        visit.upsert
      end

      def track_event(name, properties, options, &block)
        event =
          event_model.new do |e|
            e.id = binary(options[:id])
            e.visit = current_visit
            e.user = user if e.respond_to?(:user)
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end

        yield(event) if block_given?

        event.upsert
      end

      def current_visit(ahoy)
        visit_model.where(_id: binary(ahoy.visit_token)).first if ahoy.visit_token
      end

      protected

      def visit_model
        ::Visit
      end

      def event_model
        ::Ahoy::Event
      end

      def binary(token)
        ::BSON::Binary.new(token.delete("-"), :uuid)
      end

    end
  end
end
