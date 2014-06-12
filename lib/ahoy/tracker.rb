module Ahoy
  class Tracker

    def initialize(options = {})
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
    end

    def track(name, properties = {}, options = {})
      if (Ahoy.track_bots or !bot?) and !exclude?
        # publish to each subscriber
        options = options.dup
        if @controller
          options[:controller] ||= @controller
          options[:user] ||= Ahoy.fetch_user(@controller)
          if @controller.respond_to?(:current_visit)
            options[:visit] ||= @controller.current_visit
          end
        end
        options[:time] ||= Time.zone.now
        options[:id] ||= Ahoy.generate_id

        subscribers = Ahoy.subscribers
        if subscribers.any?
          subscribers.each do |subscriber|
            subscriber.track(name, properties, options)
          end
        else
          $stderr.puts "No subscribers"
        end
      end

      true
    end

    protected

    def bot?
      @bot ||= Browser.new(ua: @request.user_agent).bot?
    end

    def exclude?
      if Ahoy.exclude_method
        if Ahoy.exclude_method.arity == 1
          Ahoy.exclude_method.call(@controller)
        else
          Ahoy.exclude_method.call(@controller, @request)
        end
      else
        false
      end
    end

  end
end
