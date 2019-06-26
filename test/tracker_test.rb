require_relative "test_helper"

class TrackerTest < Minitest::Test
  def test_no_request
    ahoy = Ahoy::Tracker.new
    assert ahoy.track("Some event", some_prop: true)
  end

  def test_user_option
    user = OpenStruct.new(id: "123")
    ahoy = Ahoy::Tracker.new(user: user)
    assert_equal ahoy.user.id, user.id
  end
end
