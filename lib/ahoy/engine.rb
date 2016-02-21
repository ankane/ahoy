module Ahoy
  class Engine < ::Rails::Engine
    initializer "ahoy.middleware", after: "sprockets.environment" do
      Rails::Rack::Logger.send(:prepend, Ahoy::LogSilencer) if Ahoy.quiet
    end
  end
end
