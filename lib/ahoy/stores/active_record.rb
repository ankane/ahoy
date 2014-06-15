module Ahoy
  module Stores
    class ActiveRecord

      def initialize(options = {})
        @options = options
        @model = options[:model] || Ahoy::Event
      end

      def track_event(name, properties, options)
        unless @options[:track_events] == false
          @model.create! do |e|
            e.visit = options[:visit]
            e.user = options[:user]
            e.name = name
            e.properties = properties
            e.time = options[:time]
          end
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

      # TODO much better interface
      def track_visit(ahoy)
        visit =
          Ahoy.visit_model.new do |v|
            v.visit_token = ahoy.visit_token
            v.visitor_token = ahoy.visitor_token
            v.user = ahoy.user if v.respond_to?(:user=)
          end

        Ahoy::Request::KEYS.each do |key|
          visit.send(:"#{key}=", ahoy.ahoy_request.send(key)) if visit.respond_to?(:"#{key}=")
        end

        begin
          visit.save!
        rescue ActiveRecord::RecordNotUnique
          # do nothing
        end
      end

      def current_visit(ahoy)
        Ahoy.visit_model.where(visit_token: ahoy.visit_token).first if ahoy.visit_token
      end

    end
  end
end
