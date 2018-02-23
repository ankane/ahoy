require_relative "test_helper"

class TestVisitProperties < Minitest::Test
  def setup
    @request = MiniTest::Mock.new
    @visit_properties = Ahoy::VisitProperties.new(@request)
  end

  def test_keys
    with_geocode(true) do
      assert_equal @visit_properties.keys, Ahoy::VisitProperties::KEYS
    end
  end

  def test_keys_when_geocode_disabled
    with_geocode(false) do
      keys = @visit_properties.keys

      refute keys.include?(:country)
      refute keys.include?(:region)
      refute keys.include?(:city)
    end
  end

  def test_keys_when_geocode_async
    with_geocode(:async) do
      keys = @visit_properties.keys

      refute keys.include?(:country)
      refute keys.include?(:region)
      refute keys.include?(:city)
    end
  end

  def test_user_agent_header_encoding
    raw_user_agent = "FBCR/M\xE9ditel"
    encoded_user_agent = "FBCR/Méditel"
    2.times { @request.expect(:user_agent, raw_user_agent) }
    assert_equal @visit_properties.user_agent, encoded_user_agent
  end

  def test_nil_user_agent
    @request.expect(:user_agent, nil)
    assert_equal @visit_properties.user_agent, nil
  end

  private

  def with_geocode(enabled)
    original = Ahoy.geocode
    Ahoy.geocode = enabled
    yield
  ensure
    Ahoy.geocode = original
  end
end
