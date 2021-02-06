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

  def test_user_option
    user = OpenStruct.new(id: 123)
    ahoy = Ahoy::Tracker.new(user: user)
    assert_equal ahoy.user.id, user.id

    ahoy.track("Some event", some_prop: true)

    event = Ahoy::Event.last
    assert_equal user.id, event.user_id
  end
end
