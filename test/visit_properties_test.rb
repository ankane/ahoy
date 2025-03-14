require_relative "test_helper"

class VisitPropertiesTest < ActionDispatch::IntegrationTest
  def test_standard
    referrer = "http://www.example.com"
    get products_url, headers: {"Referer" => referrer}

    visit = Ahoy::Visit.last
    assert_equal referrer, visit.referrer
    assert_equal "www.example.com", visit.referring_domain
    assert_equal "http://www.example.com/products", visit.landing_page
    assert_equal "127.0.0.1", visit.ip
  end

  def test_utm_params
    get products_url(
      utm_source: "test-source",
      utm_medium: "test-medium",
      utm_term: "test-term",
      utm_content: "test-content",
      utm_campaign: "test-campaign"
    )

    visit = Ahoy::Visit.last
    assert_equal "test-source", visit.utm_source
    assert_equal "test-medium", visit.utm_medium
    assert_equal "test-term", visit.utm_term
    assert_equal "test-content", visit.utm_content
    assert_equal "test-campaign", visit.utm_campaign
  end

  def test_tech
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:78.0) Gecko/20100101 Firefox/78.0"
    get products_url, headers: {"User-Agent" => user_agent}

    visit = Ahoy::Visit.last
    assert_equal user_agent, visit.user_agent
    assert_equal "Firefox", visit.browser
    assert_equal "Mac", visit.os
    assert_equal "Desktop", visit.device_type
  end

  def test_legacy_user_agent_parser
    with_options(user_agent_parser: :legacy) do
      user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:78.0) Gecko/20100101 Firefox/78.0"
      get products_url, headers: {"User-Agent" => user_agent}

      visit = Ahoy::Visit.last
      assert_equal user_agent, visit.user_agent
      assert_equal "Firefox", visit.browser
      assert_equal "Mac OS X", visit.os
      assert_equal "Desktop", visit.device_type
    end
  end
end
