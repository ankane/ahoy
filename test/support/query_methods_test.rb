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

    skip "Values are always strings" if hstore?

    create_event value: 1
    create_event value: 1
    create_event value: 9
    expected = {1 => 2, 9 => 1}
    assert_equal expected, group_events
  end

  def test_group_boolean
    skip unless group_supported?

    skip "Values are always strings" if hstore?

    create_event value: true
    create_event value: true
    create_event value: false
    expected = {true => 2, false => 1}
    assert_equal expected, group_events
  end

  def test_group_nil
    skip unless group_supported?

    create_event value: nil
    create_event value: nil
    create_event value: "world"
    expected = {nil => 2, "world" => 1}
    assert_equal expected, group_events
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

  def hstore?
    self.class.name == "PostgresqlHstoreTest"
  end

  def group_supported?
    self.class.name != "MongoidTest" && !model.connection.try(:mariadb?)
  end
end
