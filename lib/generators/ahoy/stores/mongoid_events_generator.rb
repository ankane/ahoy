require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class MongoidEventsGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        def generate_model
          template "mongoid_event_model.rb", "app/models/ahoy/event.rb"
        end

        def create_initializer
          template "mongoid_initializer.rb", "config/initializers/ahoy.rb"
        end
      end
    end
  end
end
