module Ahoy
  class Engine < ::Rails::Engine
    initializer "ahoy.middleware", after: "sprockets.environment" do |app|
      Rails::Rack::Logger.send(:prepend, Ahoy::LogSilencer) if Ahoy.quiet

      if Ahoy.throttle
        require "ahoy/throttle"
        app.middleware.use Ahoy::Throttle
      end
    end
  end
end
