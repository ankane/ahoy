require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class MongoidGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        def generate_visit_model
          template "mongoid_visit_model.rb", "app/models/visit.rb"
        end

        def generate_event_model
          template "mongoid_event_model.rb", "app/models/ahoy/event.rb"
        end

        def create_initializer
          template "mongoid_initializer.rb", "config/initializers/ahoy.rb"
        end

      end
    end
  end
end
