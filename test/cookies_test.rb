require_relative "test_helper"

class CookiesTest < ActionDispatch::IntegrationTest
  def test_cookies_true
    get products_url
    assert_equal ["ahoy_visit", "ahoy_visitor"], response.cookies.keys.sort
  end

  def test_cookies_false
    error = assert_raises do
      Ahoy.cookies = false
    end
    assert_match "This feature requires a new index", error.message
  end

  def test_cookies_none
    with_options(cookies: :none) do
      get products_url
      assert_empty response.cookies
      visit = Ahoy::Visit.last

      # deterministic token
      assert_equal "93dc5253-3a3b-561d-8d53-fb5476f02eca", visit.visitor_token

      get products_url
      assert_equal 1, Ahoy::Visit.count
      assert_equal 2, Ahoy::Visit.last.events.count
    end
  end

  def test_cookies_none_deletes_cookies
    self.cookies["ahoy_visit"] = "test-token"
    self.cookies["ahoy_visitor"] = "test-token"
    self.cookies["ahoy_track"] = "true"

    with_options(cookies: :none) do
      get products_url
      expired = "max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
      assert_equal 3, set_cookie_header.scan(expired).size
    end
  end

  def test_cookie_options
    with_options(cookie_options: {same_site: :lax}) do
      get products_url
      assert_match /samesite=lax/i, set_cookie_header
    end
  end

  def test_cookie_domain
    with_options(cookie_domain: :all) do
      get products_url
      # leading dot removed in Rails 7.1
      # https://github.com/rails/rails/pull/48036
      assert_match /domain=.?example\.com/, set_cookie_header
    end
  end

  private

  def set_cookie_header
    header = response.header["Set-Cookie"]
    header.is_a?(Array) ? header.join("\n") : header
  end
end
