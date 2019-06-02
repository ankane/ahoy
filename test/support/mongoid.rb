Mongoid.logger.level = Logger::WARN
Mongo::Logger.logger.level = Logger::WARN

Mongoid.configure do |config|
  config.connect_to("ahoy_test")
end
