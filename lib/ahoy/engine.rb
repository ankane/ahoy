module Ahoy
  class Engine < ::Rails::Engine
    # from https://github.com/evrone/quiet_assets/blob/master/lib/quiet_assets.rb
    initializer "ahoy.middleware", after: "sprockets.environment" do
      next unless Ahoy.quiet

      # Parse PATH_INFO by assets prefix
      AHOY_PREFIX = "/ahoy/".freeze
      KEY = "ahoy.old_level".freeze

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
        alias_method_chain :call, :quiet_ahoy
      end
    end
  end
end
