require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"

ENV["ADAPTER"] ||= "sqlite3"
puts "Using #{ENV["ADAPTER"]}"

logger = ActiveSupport::Logger.new(ENV["VERBOSE"] ? STDOUT : nil)

frameworks = [:action_controller, :active_job]

if ENV["ADAPTER"] == "mongoid"
  require_relative "support/mongoid"

  Dir.glob("support/mongoid_models/**/*.rb", base: __dir__) do |file|
    require_relative file
  end

  Mongoid.logger = logger
  Mongo::Logger.logger = logger

  [Ahoy::Visit, Ahoy::Event].each do |model|
    model.collection.drop
    model.create_indexes
  end
else
  frameworks << :active_record
end

if ENV["ADAPTER"] == "trilogy"
  Combustion::Database::Reset::OPERATOR_PATTERNS[Combustion::Databases::MySQL] << /trilogy/
end

Combustion.path = "test/internal"
Combustion.initialize!(*frameworks) do
  config.load_defaults Rails::VERSION::STRING.to_f

  if ENV["ADAPTER"] != "mongoid"
    config.active_record.logger = logger
  end

  config.action_controller.logger = logger
  config.active_job.logger = logger
end

Ahoy.logger = logger

class Minitest::Test
  def setup
    Ahoy::Visit.delete_all
    Ahoy::Event.delete_all
    User.delete_all
  end

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
