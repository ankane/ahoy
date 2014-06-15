require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class MongoidGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        def generate_visit_model
          invoke "mongoid:model", ["Visit"]
        end

        # needed to call invoke task more than once
        # http://stackoverflow.com/questions/4331267/call-task-more-than-once-in-rails-3-generator
        def generate_event_model
          Rails::Generators.invoke "mongoid:model", ["Ahoy::Event"]
        end

        def create_initializer
          template "mongoid_initializer.rb", "config/initializers/ahoy.rb"
        end

      end
    end
  end
end
