require "rails/generators"

module Ahoy
  module Stores
    module Generators
      class ActiveRecordGenerator < Rails::Generators::Base
        class_option :database, type: :string, aliases: "-d"

        def boom
          invoke "ahoy:stores:active_record_visits", nil, options
          invoke "ahoy:stores:active_record_events", nil, options
        end
      end
    end
  end
end
