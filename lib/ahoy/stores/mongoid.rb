module Ahoy
  module Stores
    class Mongoid

      def initialize(options = {})
        @options = options
      end

      def track_visit(ahoy, &block)
        visit =
          visit_model.new do |v|
            v.id = binary(ahoy.visit_token)
            v.visitor_token = binary(ahoy.visitor_token)
            v.user = ahoy.user if v.respond_to?(:user=) && ahoy.user
          end

        Ahoy::Request::KEYS.each do |key|
          visit.send(:"#{key}=", ahoy.ahoy_request.send(key)) if visit.respond_to?(:"#{key}=") && ahoy.ahoy_request.send(key)
        end

        yield(visit) if block_given?

        visit.upsert
      end

      def track_event(name, properties, options)
        unless @options[:track_events] == false
          event =
            event_model.new do |e|
              e.id = binary(options[:id])
              e.visit = options[:visit]
              e.user = options[:user] if e.respond_to?(:user)
              e.name = name
              e.properties = properties
              e.time = options[:time]
            end

          event.upsert
        end
      end

      def current_visit(ahoy)
        visit_model.where(_id: binary(ahoy.visit_token)).first if ahoy.visit_token
      end

      protected

      def visit_model
        @options[:visit_model] || Ahoy.visit_model
      end

      def event_model
        @options[:event_model] || ::Ahoy::Event
      end

      def binary(token)
        ::BSON::Binary.new(token.delete("-"), :uuid)
      end

    end
  end
end
