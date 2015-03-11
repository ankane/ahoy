require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class MongoidVisitsGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        def generate_model
          @visitor_id_type =
            if defined?(::BSON)
              "BSON::Binary"
            elsif defined?(::Moped::BSON)
              "Moped::BSON::Binary"
            else
              "String"
            end
          template "mongoid_visit_model.rb", "app/models/visit.rb"
        end

        def create_initializer
          template "mongoid_initializer.rb", "config/initializers/ahoy.rb"
        end
      end
    end
  end
end
