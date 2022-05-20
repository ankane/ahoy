require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  def test_works
    get products_url
    assert_response :success

    assert_equal 1, Ahoy::Visit.count
    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal "Viewed products", event.name
    assert_equal({}, event.properties)
  end

  def test_instance
    post products_url
    assert_response :success

    assert_equal 1, Ahoy::Visit.count
    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal "Created product", event.name
    product = Product.last
    assert_equal({"product_id" => product.id}, event.properties)
  end

  def test_server_side_visits_true
    with_options(server_side_visits: true) do
      get list_products_url
      assert_equal 1, Ahoy::Visit.count
    end
  end

  def test_server_side_visits_false
    with_options(server_side_visits: false) do
      get products_url
      assert_equal 0, Ahoy::Visit.count
      assert_equal ["ahoy_track", "ahoy_visit", "ahoy_visitor"], response.cookies.keys.sort
    end
  end

  def test_server_side_visits_when_needed
    with_options(server_side_visits: :when_needed) do
      get list_products_url
      assert_equal 0, Ahoy::Visit.count
      get products_url
      assert_equal 1, Ahoy::Visit.count
    end
  end

  def test_skip_before_action
    get no_visit_products_url
    assert_equal 0, Ahoy::Visit.count
  end

  def test_api_only
    with_options(api_only: true) do
      get list_products_url
      assert_equal 0, Ahoy::Visit.count
      assert_empty response.cookies
    end
  end

  def test_visit_duration
    get products_url
    travel 5.hours do
      get products_url
    end
    assert_equal 2, Ahoy::Visit.count
    assert_equal 1, Ahoy::Visit.pluck(:visitor_token).uniq.count
  end

  def test_visit_duration_cookies_false
    with_options(cookies: false) do
      get products_url
      travel 5.hours do
        get products_url
      end
      assert_equal 1, Ahoy::Visit.count
      assert_equal 1, Ahoy::Visit.pluck(:visitor_token).uniq.count
    end
  end

  def test_visitor_duration
    get products_url
    travel 3.years do
      get products_url
    end
    assert_equal 2, Ahoy::Visit.count
    assert_equal 2, Ahoy::Visit.pluck(:visitor_token).uniq.count
  end

  def test_visitor_duration_cookies_false
    with_options(cookies: false) do
      get products_url
      travel 3.years do
        get products_url
      end
      assert_equal 1, Ahoy::Visit.count
      assert_equal 1, Ahoy::Visit.pluck(:visitor_token).uniq.count
    end
  end

  def test_mask_ips
    with_options(mask_ips: true) do
      get products_url
      assert_equal "127.0.0.0", Ahoy::Visit.last.ip
    end
  end

  def test_token_generator
    token_generator = -> { "test-token" }
    with_options(token_generator: token_generator) do
      get products_url
      visit = Ahoy::Visit.last
      assert_equal "test-token", visit.visit_token
      assert_equal "test-token", visit.visitor_token
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
end
