require_relative "test_helper"

class CookieJarTest < Minitest::Test

  def setup
    @cookies = {}
    @subject = Ahoy::CookieJar.new(@cookies)
  end

  def test_sets_value
    @subject.set_cookie("some_cookie", "some_value")

    cookie = @cookies["some_cookie"]

    assert_equal cookie[:value], "some_value"
  end

  def test_sets_expire_if_duration_specified
    @subject.set_cookie("some_cookie", "some_value", 30.minutes)

    cookie = @cookies["some_cookie"]

    assert_in_delta cookie[:expires], 30.minutes.from_now, 0.001
  end

  def test_sets_ahoy_cookie_domain_if_use_domain_specified
    with_ahoy_setting(:cookie_domain, "cookie_domain") do
      @subject.set_cookie("some_cookie", "some_value", nil, true)

      cookie = @cookies["some_cookie"]

      assert_equal cookie[:domain], "cookie_domain"
    end
  end

  def test_sets_ahoy_domain_if_use_domain_specified_and_no_cookie_domain_set
    with_ahoy_setting(:cookie_domain, nil) do
      with_ahoy_setting(:domain, "ahoy_domain") do
        @subject.set_cookie("some_cookie", "some_value", nil, true)

        cookie = @cookies["some_cookie"]

        assert_equal cookie[:domain], "ahoy_domain"
      end
    end
  end

  private

  def with_ahoy_setting(setting, value)
    setter_method = :"#{setting}="
    original_value = Ahoy.public_send(setting)
    Ahoy.public_send(setter_method, value)
    yield
  ensure
    Ahoy.public_send(setter_method, original_value)
  end
end
