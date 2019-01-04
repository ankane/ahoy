require 'minitest/autorun'
require 'ahoy/tracker'
require 'ahoy/base_store'
require 'active_support'
require 'active_support/core_ext'

module Ahoy
  class Store < Ahoy::BaseStore
  end
end

module Ahoy
  mattr_accessor :cookies
  self.cookies = true

  mattr_accessor :api_only
  self.api_only = false
end

module Ahoy
  class TestTracker < Minitest::Test
    def test_ensure_token_removes_invalid_utf8_bytes_from_visit_token_cookie
      mock_request = Struct.new(:cookies, :headers)
      request = mock_request.new({ 'ahoy_visit' => "bad token\255" }, {})
      tracker = Tracker.new(request: request)

      assert tracker.visit_token, 'bad token'
    end

    def test_ensure_token_removes_invalid_utf8_bytes_from_visitor_token_cookie
      mock_request = Struct.new(:cookies, :headers)
      request = mock_request.new({ 'ahoy_visitor' => "bad token\255" }, {})
      tracker = Tracker.new(request: request)

      assert tracker.visitor_token, 'bad token'
    end

    def test_ensure_token_removes_invalid_utf8_bytes_from_visit_token_header
      mock_request = Struct.new(:cookies, :headers)
      request = mock_request.new({}, 'Ahoy-Visit' => "bad token\255")
      tracker = Tracker.new(request: request)

      assert tracker.visit_token, 'bad token'
    end

    def test_ensure_token_removes_invalid_utf8_bytes_from_visitor_token_header
      mock_request = Struct.new(:cookies, :headers)
      request = mock_request.new({}, 'Ahoy-Visitor' => "bad token\255")
      tracker = Tracker.new(request: request)

      assert tracker.visitor_token, 'bad token'
    end
  end
end
