require_relative "test_helper"

class CookiesTest < ActionDispatch::IntegrationTest
  def test_cookies_true
    get products_url
    assert_equal ["ahoy_visit", "ahoy_visitor"], response.cookies.keys.sort
  end

  def test_cookies_false
    with_options(cookies: false) do
      get products_url
      assert_empty response.cookies
      visit = Ahoy::Visit.last
      # deterministic tokens
      if Rails::VERSION::MAJOR >= 7
        assert_equal "f53976f4-229b-5ff7-9b66-98bbbbfac543", visit.visit_token
        assert_equal "93dc5253-3a3b-561d-8d53-fb5476f02eca", visit.visitor_token
      else
        assert_equal "8924a60c-5c50-5d80-b38d-e6c68fcd0958", visit.visit_token
        assert_equal "64dcde66-9659-5473-897e-5abd59f8b89f", visit.visitor_token
      end

      get products_url
      assert_equal 1, Ahoy::Visit.count
      assert_equal 2, Ahoy::Visit.last.events.count
    end
  end

  def test_cookies_false_deletes_cookies
    self.cookies["ahoy_visit"] = "test-token"
    self.cookies["ahoy_visitor"] = "test-token"
    self.cookies["ahoy_track"] = "true"

    with_options(cookies: false) do
      get products_url
      expired = "max-age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT"
      assert_equal 3, response.headers["Set-Cookie"].scan(expired).size
    end
  end

  def test_cookie_options
    with_options(cookie_options: {same_site: :lax}) do
      get products_url
      assert_match "SameSite=Lax", response.header["Set-Cookie"]
    end
  end

  def test_cookie_domain
    with_options(cookie_domain: :all) do
      get products_url
      assert_match "domain=.example.com", response.header["Set-Cookie"]
    end
  end
end
