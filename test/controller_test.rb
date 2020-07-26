require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def setup
    Ahoy::Visit.delete_all
    Ahoy::Event.delete_all
  end

  def test_works
    get products_url
    assert :success

    assert_equal 1, Ahoy::Visit.count
    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal "Viewed products", event.name
  end

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

  def test_visitable
    post products_url
    visit = Ahoy::Visit.last
    assert_equal visit, Product.last.ahoy_visit
  end

  def test_mask_ips
    with_mask_ips do
      get products_url
      assert_equal "127.0.0.0", Ahoy::Visit.last.ip
    end
  end

  def test_bad_visit_cookie
    make_request(cookies: {"ahoy_visit" => "badtoken\255"})
    assert_equal ahoy.visit_token, "badtoken"
  end

  def test_bad_visitor_cookie
    make_request(cookies: {"ahoy_visitor" => "badtoken\255"})
    assert_equal ahoy.visitor_token, "badtoken"
  end

  def test_bad_visit_header
    make_request(headers: {"Ahoy-Visit" => "badtoken\255"})
    assert_equal ahoy.visit_token, "badtoken"
  end

  def test_bad_visitor_header
    make_request(headers: {"Ahoy-Visitor" => "badtoken\255"})
    assert_equal ahoy.visitor_token, "badtoken"
  end

  private

  def make_request(cookies: {}, headers: {})
    cookies.each do |k, v|
      self.cookies[k] = v
    end
    get products_url, headers: headers
    assert_response :success
  end

  def ahoy
    controller.ahoy
  end

  def with_mask_ips
    previous_value = Ahoy.mask_ips
    begin
      Ahoy.mask_ips = true
      yield
    ensure
      Ahoy.mask_ips = previous_value
    end
  end
end
