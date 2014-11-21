require_relative '../test_helper'

class TestVisitProperties < Minitest::Test
  def setup
    request = MiniTest::Mock.new
    @visit_properties = Ahoy::VisitProperties.new(request)
  end

  def test_keys
    assert_equal @visit_properties.keys, Ahoy::VisitProperties::KEYS
  end

  def test_keys_when_geocode_disabled
    Ahoy.geocode = false
    keys = @visit_properties.keys

    refute keys.include?(:country)
    refute keys.include?(:region)
    refute keys.include?(:city)
  end
end
