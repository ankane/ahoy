require_relative "test_helper"

module Ahoy
  class Store < Ahoy::BaseStore
  end
end

class TrackerTest < Minitest::Test
  def test_ensure_token_removes_invalid_utf8_bytes_from_visit_token_cookie
    tracker = build_tracker(cookies: {"ahoy_visit" => "bad token\255"})
    assert tracker.visit_token, "bad token"
  end

  def test_ensure_token_removes_invalid_utf8_bytes_from_visitor_token_cookie
    tracker = build_tracker(cookies: {"ahoy_visitor" => "bad token\255"})
    assert tracker.visitor_token, "bad token"
  end

  def test_ensure_token_removes_invalid_utf8_bytes_from_visit_token_header
    tracker = build_tracker(headers: {"Ahoy-Visit" => "bad token\255"})
    assert tracker.visit_token, "bad token"
  end

  def test_ensure_token_removes_invalid_utf8_bytes_from_visitor_token_header
    tracker = build_tracker(headers: {"Ahoy-Visitor" => "bad token\255"})
    assert tracker.visitor_token, "bad token"
  end

  private

  def build_tracker(cookies: {}, headers: {})
    mock_request = Struct.new(:cookies, :headers)
    request = mock_request.new(cookies, headers)
    Ahoy::Tracker.new(request: request)
  end
end
