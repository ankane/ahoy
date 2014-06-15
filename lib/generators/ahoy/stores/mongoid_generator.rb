require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class MongoidGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        def generate_visit_model
          invoke "mongoid:model", ["Visit"]
        end

        def generate_event_model
          invoke "mongoid:model", ["Ahoy::Event"]
        end

        def create_initializer
          template "mongoid_initializer.rb", "config/initializers/ahoy.rb"
        end

      end
    end
  end
end
