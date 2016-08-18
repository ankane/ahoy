module Ahoy
  class Engine < ::Rails::Engine
    initializer "ahoy.middleware", after: "sprockets.environment" do |app|
      next unless Ahoy.quiet

      # Parse PATH_INFO by assets prefix
      AHOY_PREFIX = "/ahoy/".freeze

      # Just create an alias for call in middleware
      Rails::Rack::Logger.class_eval do
        def call_with_quiet_ahoy(env)
          if env["PATH_INFO"].start_with?(AHOY_PREFIX) && logger.respond_to?(:silence_logger)
            logger.silence_logger do
              call_without_quiet_ahoy(env)
            end
          else
            call_without_quiet_ahoy(env)
          end
        end
        alias_method :call_without_quiet_ahoy, :call
        alias_method :call, :call_with_quiet_ahoy
      end
    end
  end
end
