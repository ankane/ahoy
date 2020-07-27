require "bundler/setup"
Bundler.require(:development)
require "minitest/autorun"
require "minitest/pride"

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

class Minitest::Test
  def with_options(options)
    previous_options = {}
    options.each_key do |k|
      previous_options[k] = Ahoy.send(k)
    end
    begin
      options.each do |k, v|
        Ahoy.send("#{k}=", v)
      end
      yield
    ensure
      previous_options.each do |k, v|
        Ahoy.send("#{k}=", v)
      end
    end
  end
end
