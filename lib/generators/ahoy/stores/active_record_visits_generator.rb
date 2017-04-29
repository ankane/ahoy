# taken from https://github.com/collectiveidea/audited/blob/master/lib/generators/audited/install_generator.rb
require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"

module Ahoy
  module Stores
    module Generators
      class ActiveRecordVisitsGenerator < Rails::Generators::Base
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
          unless options["database"].in?([nil, "postgresql", "postgresql-jsonb"])
            raise Thor::Error, "Unknown database option"
          end
          migration_template "active_record_visits_migration.rb", "db/migrate/create_visits.rb", migration_version: migration_version
        end

        def generate_model
          template "active_record_visit_model.rb", "app/models/visit.rb"
        end

        def create_initializer
          template "active_record_initializer.rb", "config/initializers/ahoy.rb"
        end

        def migration_version
          if ActiveRecord::VERSION::MAJOR >= 5
            "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
          end
        end
      end
    end
  end
end
