require_relative "../test_helper"

Mongoid.logger.level = Logger::WARN
Mongo::Logger.logger.level = Logger::WARN

Mongoid.configure do |config|
  config.connect_to("ahoy_test")
end

class MongoidEvent
  include Mongoid::Document
  include Ahoy::QueryMethods

  field :properties, type: Hash
end

class MongoidTest < Minitest::Test
  include QueryMethodsTest

  def model
    MongoidEvent
  end
end
