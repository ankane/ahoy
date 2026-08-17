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

    with_options(cookies: :none) do
      ahoy = Ahoy::Tracker.new(request: request)
      ahoy.track("Some event", some_prop: true)
    end

    event = Ahoy::Event.last
    assert_equal "Some event", event.name
    assert_equal({"some_prop" => true}, event.properties)
    assert_nil event.user_id
  end

  def test_no_cookies_no_request
    with_options(cookies: :none) do
      ahoy = Ahoy::Tracker.new
      ahoy.track("Some event", some_prop: true)
    end

    event = Ahoy::Event.last
    assert_equal "Some event", event.name
    assert_equal({"some_prop" => true}, event.properties)
    assert_nil event.user_id
  end

  # Postgres aborts the entire transaction when a statement fails, so rescuing
  # the unique violation in Ruby is not enough to leave the transaction usable.
  # The `visitable` macro creates visits from a before_create hook, i.e. inside
  # the record's own transaction.
  def test_duplicate_visit_token_does_not_abort_transaction
    skip if ENV["ADAPTER"] == "mongoid"

    visit_token = SecureRandom.uuid
    Ahoy::Visit.create!(visit_token: visit_token, started_at: Time.current)

    ActiveRecord::Base.transaction do
      # A concurrent request already created this visit.
      Ahoy::Tracker.new(visit_token: visit_token).track_visit
      User.create!(name: "Test")
    end

    assert_equal 1, Ahoy::Visit.count
    assert_equal 1, User.count
  end

  def test_user_option
    user = Struct.new(:id).new(123)
    ahoy = Ahoy::Tracker.new(user: user)
    assert_equal ahoy.user.id, user.id

    ahoy.track("Some event", some_prop: true)

    event = Ahoy::Event.last
    assert_equal user.id, event.user_id
  end

  def test_user_option_in_store
    user = Struct.new(:id, :user_prop).new(123, 42)
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
