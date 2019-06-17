module Ahoy
  class ControllerTracker < RequestTracker
    def initialize(controller, **options)
      options[:user_resolver] ||= -> {
        if Ahoy.user_method.respond_to?(:call)
          Ahoy.user_method.call(controller)
        else
          controller.__send__(Ahoy.user_method)
        end
      }
    
      options[:exclude_method_resolver] ||= -> {
        if Ahoy.exclude_method
          if Ahoy.exclude_method.arity == 1
            Ahoy.exclude_method.call(controller)
          else
            Ahoy.exclude_method.call(controller, controller.request)
          end
        else
          false
        end
      }
    
      super(controller.request, **options)
    end
  end
end
