# taken from https://github.com/collectiveidea/audited/blob/master/lib/generators/audited/install_generator.rb
require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"

module Ahoy
  module Generators
    class ActiverecordGenerator < Rails::Generators::Base
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

      def copy_templates
        template "database_store_initializer.rb", "config/initializers/ahoy.rb"
        template "active_record_visit_model.rb", "app/models/ahoy/visit.rb"
        template "active_record_event_model.rb", "app/models/ahoy/event.rb"
        migration_template "active_record_migration.rb", "db/migrate/create_ahoy_visits_and_events.rb", migration_version: migration_version
        puts "\nAlmost set! Last, run:\n\n    rails db:migrate"
      end

      def properties_type
        # use connection_config instead of connection.adapter
        # so database connection isn't needed
        case ActiveRecord::Base.connection_config[:adapter].to_s
        when /postg/i # postgres, postgis
          "jsonb"
        when /mysql/i
          "json"
        else
          "text"
        end
      end

      def rails52?
        ActiveRecord::VERSION::STRING >= "5.2"
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end
    end
  end
end
