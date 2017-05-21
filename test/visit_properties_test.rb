require_relative "test_helper"

class TestVisitProperties < Minitest::Test

  def test_keys
    with_geocode(true) do
      assert_equal visit_properties.keys, Ahoy::VisitProperties::KEYS

      visit_properties.keys.each{ |key| visit_properties[key] }
    end
  end

  def test_keys_when_geocode_disabled
    with_geocode(false) do
      keys = visit_properties.keys

      refute keys.include?(:country)
      refute keys.include?(:region)
      refute keys.include?(:city)
    end
  end

  def test_keys_when_geocode_async
    with_geocode(:async) do
      keys = visit_properties.keys

      refute keys.include?(:country)
      refute keys.include?(:region)
      refute keys.include?(:city)
    end
  end

  private

  def with_geocode(enabled)
    original = Ahoy.geocode
    Ahoy.geocode = enabled
    yield
  ensure
    Ahoy.geocode = original
  end

  def visit_properties
    request = request_mock
    @visit_properties = Ahoy::VisitProperties.new(request)
  end

  def request_mock
    request_mock = MiniTest::Mock.new
    request_mock.expect(:remote_ip, "0.0.0.0")
    request_mock.expect(:user_agent, "User-Agent")
    request_mock.expect(:referer, "localhost")
    request_mock.expect(:original_url, "http://0.0.0.0/ahoy")
    request_mock.expect(:params, { "referrer" => "localhost",
                                 "landing_page" => "visits",
                                 "platform" => "A",
                                 "app_version" => "1",
                                 "os_version" => "2",
                                 "screen_height" => "1200",
                                 "screen_width" => "1920" })
  end
end
