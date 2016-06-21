require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]

module PropertiesTest
  def setup
    Ahoy::Event.delete_all
  end

  def test_empty
    assert_equal 0, Ahoy::Event.where_properties({}).count
  end

  def test_string
    create_event hello: "world"
    assert_equal 1, Ahoy::Event.where_properties(hello: "world").count
  end

  def test_number
    create_event product_id: 1
    assert_equal 1, Ahoy::Event.where_properties(product_id: 1).count
  end

  def create_event(properties)
    Ahoy::Event.create(properties: properties)
  end
end
