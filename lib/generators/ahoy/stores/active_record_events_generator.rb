# taken from https://github.com/collectiveidea/audited/blob/master/lib/generators/audited/install_generator.rb
require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"

module Ahoy
  module Stores
    module Generators
      class ActiveRecordEventsGenerator < Rails::Generators::Base
        include Rails::Generators::Migration
        source_root File.expand_path("../templates", __FILE__)

        class_option :database, type: :string, aliases: "-d"

        # Implement the required interface for Rails::Generators::Migration.
        def self.next_migration_number(dirname) #:nodoc:
          next_migration_number = current_migration_number(dirname) + 1
          if ::ActiveRecord::Base.timestamped_migrations
            [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
          else
            "%.3d" % next_migration_number
          end
        end

        def copy_migration
          @database = options["database"] || detect_database
          unless @database.in?([nil, "postgresql", "postgresql-jsonb", "mysql", "sqlite"])
            raise Thor::Error, "Unknown database option"
          end
          migration_template "active_record_events_migration.rb", "db/migrate/create_ahoy_events.rb"
        end

        def generate_model
          template "active_record_event_model.rb", "app/models/ahoy/event.rb"
        end

        def create_initializer
          template "active_record_initializer.rb", "config/initializers/ahoy.rb"
        end

        def detect_database
          postgresql_version = ActiveRecord::Base.connection.send(:postgresql_version) rescue 0
          if postgresql_version >= 90400
            "postgresql-jsonb"
          elsif postgresql_version >= 90200
            "postgresql"
          end
        end
      end
    end
  end
end
