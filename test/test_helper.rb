require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"
require "mongoid"

Combustion.path = "test/internal"
Combustion.initialize! :all do
  if ActiveRecord::VERSION::MAJOR < 6 && config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end

  logger = ActiveSupport::Logger.new(STDOUT)
  config.active_record.logger = logger if ENV["VERBOSE"]
  config.action_mailer.logger = logger if ENV["VERBOSE"]
end

# run setup / migrations
require_relative "support/mysql"
require_relative "support/postgresql"
require_relative "support/mongoid"

# restore connection
ActiveRecord::Base.establish_connection(:test)

require_relative "support/query_methods_test"
