require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class ActiveRecordGenerator < Rails::Generators::Base

        def boom
          invoke "ahoy:stores:active_record_visits"
          invoke "ahoy:stores:active_record_events"
        end

      end
    end
  end
end
