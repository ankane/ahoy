module Ahoy
  class Tracker

    def initialize(options = {})
      @controller = options[:controller]
    end

    def track(name, properties = {}, options = {})
      if !(@controller and Ahoy.exclude_method and Ahoy.exclude_method.call(@controller))
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

  end
end
