require_relative "test_helper"

class TrackerTest < Minitest::Test
  def test_no_request
    ahoy = Ahoy::Tracker.new
    ahoy.track("Some event", some_prop: true)

    event = Ahoy::Event.last
    assert_equal "Some event", event.name
    assert_equal({"some_prop" => true}, event.properties)
    assert_nil event.user_id
  end

  def test_no_cookies
    request = ActionDispatch::TestRequest.create

    with_options(cookies: false) do
      ahoy = Ahoy::Tracker.new(request: request)
      ahoy.track("Some event", some_prop: true)
    end

    event = Ahoy::Event.last
    assert_equal "Some event", event.name
    assert_equal({"some_prop" => true}, event.properties)
    assert_nil event.user_id
  end

  def test_user_option
    user = OpenStruct.new(id: 123)
    ahoy = Ahoy::Tracker.new(user: user)
    assert_equal ahoy.user.id, user.id

    ahoy.track("Some event", some_prop: true)

    event = Ahoy::Event.last
    assert_equal user.id, event.user_id
  end

  def test_user_option_in_store
    user = OpenStruct.new(id: 123, user_prop: 42)
    ahoy = Ahoy::Tracker.new(user: user)
    ahoy.instance_variable_get(:@store).define_singleton_method(:track_event) do |data|
      data[:properties][:user_prop] = user.try(:user_prop)
      super(data)
    end

    ahoy.track("Some event", some_prop: true)

    event = Ahoy::Event.last
    assert_equal user.user_prop, event.properties["user_prop"]
  end
end
