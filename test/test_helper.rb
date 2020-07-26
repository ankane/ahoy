require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"
require "mongoid"

logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

Combustion.path = "test/internal"
Combustion.initialize! :active_record, :action_controller, :active_job do
  if ActiveRecord::VERSION::MAJOR < 6 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

  config.action_controller.logger = logger
  config.active_record.logger = logger
  config.active_job.logger = logger
end

Ahoy.logger = logger

# run setup / migrations
require_relative "support/mysql"
require_relative "support/postgresql"
require_relative "support/mongoid"

# restore connection
ActiveRecord::Base.establish_connection(:test)

require_relative "support/query_methods_test"
