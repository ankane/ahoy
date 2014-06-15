# taken from https://github.com/collectiveidea/audited/blob/master/lib/generators/audited/install_generator.rb
require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"

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
