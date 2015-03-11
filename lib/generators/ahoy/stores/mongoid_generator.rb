require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class MongoidGenerator < Rails::Generators::Base
        def boom
          invoke "ahoy:stores:mongoid_visits"
          invoke "ahoy:stores:mongoid_events"
        end
      end
    end
  end
end
