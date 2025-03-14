module QueryMethodsTest
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

  def test_group_string
    skip unless group_supported?

    create_event value: "hello"
    create_event value: "hello"
    create_event value: "world"
    expected = {"hello" => 2, "world" => 1}
    assert_equal expected, group_events
  end

  def test_group_number
    skip unless group_supported?

    create_event value: 1
    create_event value: 1
    create_event value: 9

    expected = {1 => 2, 9 => 1}
    expected.transform_keys!(&:to_s) if mysql? || mariadb? || hstore?

    assert_equal expected, group_events
  end

  def test_group_boolean
    skip unless group_supported?

    create_event value: true
    create_event value: true
    create_event value: false

    expected = {true => 2, false => 1}
    expected.transform_keys! { |k| k ? 1 : 0 } if sqlite?
    expected.transform_keys!(&:to_s) if mysql? || mariadb? || hstore?

    assert_equal expected, group_events
  end

  def test_group_nil
    skip unless group_supported?

    create_event value: nil
    create_event value: nil
    create_event value: "world"

    expected = {nil => 2, "world" => 1}
    expected.transform_keys! { |k| k.nil? ? "null" : k.to_s } if mysql? || mariadb?

    assert_equal expected, group_events
  end

  def test_group_multiple
    skip unless group_supported?

    create_event value: "hello", other: 1
    create_event value: "hello", other: 1
    create_event value: "hello", other: 2
    create_event value: "world", other: 2

    expected = {["hello", 1] => 2, ["hello", 2] => 1, ["world", 2] => 1}
    expected.transform_keys! { |k| k.map(&:to_s) } if mysql? || mariadb? || hstore?

    assert_equal expected, model.group_prop(:value, :other).count
    assert_equal expected, model.group_prop([:value, :other]).count
  end

  def test_where_event
    model.create!(name: "Test 1", properties: {value: 1})
    model.create!(name: "Test 1", properties: {value: 2})
    model.create!(name: "Test 2", properties: {value: 1})
    assert_equal 2, model.where_event("Test 1").count
    assert_equal 1, model.where_event("Test 1", {value: 1}).count
  end

  def test_scopes
    model.create!(name: "Test 1", properties: {value: "hello"})
    model.create!(name: "Test 1", properties: {value: "world"})
    model.create!(name: "Test 2", properties: {value: "hello"})

    assert_equal 2, model.where_props(value: "hello").count
    assert_equal 1, model.where(name: "Test 1").where_props(value: "hello").count
    assert_equal 1, model.where_props(value: "hello").where(name: "Test 1").count

    if group_supported?
      assert_equal({"hello" => 1, "world" => 1}, model.where(name: "Test 1").group_prop(:value).count)
      assert_equal({"hello" => 1, "world" => 1}, model.where_event("Test 1").group_prop(:value).count)
    end
  end

  def test_connection_leasing
    skip if mongoid?

    model.connection_handler.clear_active_connections!
    assert_nil model.connection_pool.active_connection?
    model.connection_pool.with_connection do
      count_events(value: 1)
      group_events
    end
    assert_nil model.connection_pool.active_connection?
  end

  def create_event(properties)
    model.create(properties: properties)
  end

  def count_events(properties)
    model.where_props(properties).count
  end

  def group_events
    model.group_prop(:value).count
  end

  def sqlite?
    self.class.name =~ /sqlite/i
  end

  def mysql?
    self.class.name =~ /mysql|trilogy/i && !model.connection.try(:mariadb?)
  end

  def mariadb?
    self.class.name =~ /mysql|trilogy/i && model.connection.try(:mariadb?)
  end

  def hstore?
    self.class.name == "PostgresqlHstoreTest"
  end

  def mongoid?
    self.class.name == "MongoidTest"
  end

  def group_supported?
    !mongoid?
  end
end
