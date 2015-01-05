require_relative "test_helper"

class TestVisitProperties < Minitest::Test
  def setup
    request = MiniTest::Mock.new
    @visit_properties = Ahoy::VisitProperties.new(request)
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

  private

  def with_geocode(enabled)
    original = Ahoy.geocode
    Ahoy.geocode = enabled
    yield
  ensure
    Ahoy.geocode = original
  end
end
