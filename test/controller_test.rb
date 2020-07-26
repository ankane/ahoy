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
