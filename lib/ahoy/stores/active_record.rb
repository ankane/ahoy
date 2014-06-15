module Ahoy
  module Stores
    class ActiveRecord

      def initialize(options = {})
        @options = options
      end

      # TODO better interface
      def track_visit(ahoy, &block)
        visit =
          visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.user = ahoy.user if v.respond_to?(:user=)
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

      def track_event(name, properties, options)
        unless @options[:track_events] == false
          event_model.new do |e|
            e.visit = options[:visit]
            e.user = options[:user]
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end

          yield(event) if block_given?

          event.save!
        end

        # deprecated
        subscribers = Ahoy.subscribers
        if subscribers.any?
          subscribers.each do |subscriber|
            subscriber.track(name, properties, options)
          end
        else
          $stderr.puts "No subscribers"
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

    end
  end
end
