require_relative "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def test_ensure_token_removes_invalid_utf8_bytes_from_visit_token_cookie
    make_request(cookies: {"ahoy_visit" => "badtoken\255"})
    assert_equal ahoy.visit_token, "badtoken"
  end

  def test_ensure_token_removes_invalid_utf8_bytes_from_visitor_token_cookie
    make_request(cookies: {"ahoy_visitor" => "badtoken\255"})
    assert_equal ahoy.visitor_token, "badtoken"
  end

  def test_ensure_token_removes_invalid_utf8_bytes_from_visit_token_header
    make_request(headers: {"Ahoy-Visit" => "badtoken\255"})
    assert_equal ahoy.visit_token, "badtoken"
  end

  def test_ensure_token_removes_invalid_utf8_bytes_from_visitor_token_header
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
