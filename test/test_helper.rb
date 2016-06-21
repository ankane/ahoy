require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"

ActiveRecord::Base.logger = ActiveSupport::Logger.new(STDOUT) if ENV["VERBOSE"]

class PostgresqlBase < ActiveRecord::Base
  include Ahoy::Properties
  establish_connection adapter: "postgresql", database: "ahoy_test"
  self.abstract_class = true
end

class MysqlBase < ActiveRecord::Base
  include Ahoy::Properties
  establish_connection adapter: "mysql2", username: "root", database: "ahoy_test"
  self.abstract_class = true
end

module PropertiesTest
  def setup
    model.delete_all
  end

  def test_empty
    assert_equal 0, count_events({})
  end

  def test_string
    create_event value: "world"
    assert_equal 1, count_events(value: "world")
  end

  def test_number
    create_event value: 1
    assert_equal 1, count_events(value: 1)
  end

  def test_date
    today = Date.today
    create_event value: today
    assert_equal 1, count_events(value: today)
  end

  def test_time
    now = Time.now
    create_event value: now
    assert_equal 1, count_events(value: now)
  end

  def test_true
    create_event value: true
    assert_equal 1, count_events(value: true)
  end

  def test_false
    create_event value: false
    assert_equal 1, count_events(value: false)
  end

  def test_nil
    create_event value: nil
    assert_equal 1, count_events(value: nil)
  end

  def test_any
    create_event hello: "world", prop2: "hi"
    assert_equal 1, count_events(hello: "world")
  end

  def test_multiple
    create_event prop1: "hi", prop2: "bye"
    assert_equal 1, count_events(prop1: "hi", prop2: "bye")
  end

  def test_multiple_order
    create_event prop2: "bye", prop1: "hi"
    assert_equal 1, count_events(prop1: "hi", prop2: "bye")
  end

  def test_partial
    create_event hello: "world"
    assert_equal 0, count_events(hello: "world", prop2: "hi")
  end

  def test_prefix
    create_event value: 123
    assert_equal 0, count_events(value: 1)
  end

  def create_event(properties)
    model.create(properties: properties)
  end

  def count_events(properties)
    model.where_properties(properties).count
  end
end
