module Ahoy
  class Engine < ::Rails::Engine
    # from https://github.com/evrone/quiet_assets/blob/master/lib/quiet_assets.rb
    initializer "ahoy", after: "sprockets.environment" do |app|
      next unless Ahoy.quiet

      # Parse PATH_INFO by assets prefix
      AHOY_PREFIX = "/ahoy/"
      KEY = "ahoy.old_level"

      # Just create an alias for call in middleware
      Rails::Rack::Logger.class_eval do
        def call_with_quiet_ahoy(env)
          begin
            if env["PATH_INFO"].start_with?(AHOY_PREFIX)
              env[KEY] = Rails.logger.level
              Rails.logger.level = Logger::ERROR
            end
            call_without_quiet_ahoy(env)
          ensure
            Rails.logger.level = env[KEY] if env[KEY]
          end
        end
        alias_method_chain :call, :quiet_ahoy
      end
    end
  end
end
