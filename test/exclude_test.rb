require_relative "test_helper"

class ExcludeTest < ActionDispatch::IntegrationTest
  def test_track_bots_true
    with_options(track_bots: true) do
      get products_url, headers: {"User-Agent" => bot_user_agent}
      assert_equal 1, Ahoy::Visit.count
    end
  end

  def test_track_bots_false
    with_options(track_bots: false) do
      get products_url, headers: {"User-Agent" => bot_user_agent}
      assert_equal 0, Ahoy::Visit.count
    end
  end

  def test_bot_detection_version_1
    with_options(track_bots: false, bot_detection_version: 1) do
      get products_url, headers: {"User-Agent" => ""}
      assert_equal 1, Ahoy::Visit.count
    end
  end

  def test_bot_detection_version_2
    with_options(track_bots: false, bot_detection_version: 2) do
      get products_url, headers: {"User-Agent" => ""}
      assert_equal 0, Ahoy::Visit.count
    end
  end

  def test_exclude_method
    calls = 0
    exclude_method = lambda do |controller, request|
      calls += 1
      request.parameters["exclude"] == "t"
    end
    with_options(exclude_method: exclude_method) do
      get products_url, params: {"exclude" => "t"}
      assert_equal 0, Ahoy::Visit.count
      assert_equal 1, calls
      get products_url
      assert_equal 1, Ahoy::Visit.count
      assert_equal 2, calls
    end
  end

  def test_exclude_method_cookies_false
    calls = 0
    exclude_method = lambda do |controller, request|
      calls += 1
      request.parameters["exclude"] == "t"
    end
    with_options(exclude_method: exclude_method, cookies: false) do
      get products_url, params: {"exclude" => "t"}
      assert_equal 0, Ahoy::Visit.count
      assert_equal 1, calls
      get products_url
      assert_equal 1, Ahoy::Visit.count
      assert_equal 2, calls
    end
  end

  private

  def bot_user_agent
    "Mozilla/5.0 (compatible; DuckDuckBot-Https/1.1; https://duckduckgo.com/duckduckbot)"
  end
end
