module Ahoy
  module Stores
    class Mongoid

      def initialize(options = {})
        @options = options
      end

      def track_visit(ahoy)
        visit = Ahoy.visit_model.new

        visit[:visitor_token] = binary(ahoy.visitor_token)
        visit[:user_id] = ahoy.user.id if ahoy.user
        visit.assign_attributes(ahoy.ahoy_request.attributes.select{|k, v| v })

        visit.id = binary(ahoy.visit_token)
        visit.upsert
      end

      def track_event(name, properties, options)
        unless @options[:track_events] == false
          event =
            event_model.new(
              name: name,
              properties: properties,
              time: options[:time]
            )

          event[:visit_id] = options[:visit].id if options[:visit]
          event[:user_id] = options[:user].id if options[:user]

          event.id = binary(options[:id])
          event.upsert
        end
      end

      def current_visit(ahoy)
        visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
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
