require "bundler/setup"
require "combustion"
Bundler.require(:default)
require "minitest/autorun"

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

  def stub_method(cls, method, code)
    original_code = cls.method(method)
    begin
      cls.singleton_class.undef_method(method)
      cls.define_singleton_method(method, code.respond_to?(:call) ? code : ->(*) { code })
      yield
    ensure
      cls.singleton_class.undef_method(method) if cls.singleton_class.method_defined?(method)
      cls.define_singleton_method(method, original_code)
    end
  end
end
