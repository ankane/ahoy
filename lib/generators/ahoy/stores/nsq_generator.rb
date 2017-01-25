require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class NsqGenerator < Rails::Generators::Base
        source_root File.expand_path("../templates", __FILE__)

        def create_initializer
          template "nsq_initializer.rb", "config/initializers/ahoy.rb"
        end
      end
    end
  end
end
