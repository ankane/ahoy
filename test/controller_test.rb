require_relative "test_helper"

class ControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper # for Rails < 6

  def setup
    Ahoy::Visit.delete_all
    Ahoy::Event.delete_all
    User.delete_all
  end

  def test_works
    get products_url
    assert_response :success

    assert_equal 1, Ahoy::Visit.count
    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal "Viewed products", event.name
    assert_equal({}, event.properties)
  end

  def test_user
    User.create!(name: "Test User")
    get products_url
    visit = Ahoy::Visit.last
    assert_equal "Test User", visit.user.name
  end

  def test_user_method_symbol
    with_options(user_method: :true_user) do
      get products_url
      visit = Ahoy::Visit.last
      assert_equal "True User", visit.user.name
    end
  end

  def test_user_method_callable
    with_options(user_method: ->(controller) { controller.send(:true_user) }) do
      get products_url
      visit = Ahoy::Visit.last
      assert_equal "True User", visit.user.name
    end
  end

  def test_user_method_callable_request
    with_options(user_method: ->(controller, request) { request.env["action_controller.instance"].send(:true_user) }) do
      get products_url
      visit = Ahoy::Visit.last
      assert_equal "True User", visit.user.name
    end
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

  def test_visitable
    post products_url
    visit = Ahoy::Visit.last
    assert_equal visit, Product.last.ahoy_visit
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

  def test_authenticate
    get products_url
    visit = Ahoy::Visit.last
    assert_nil visit.user
    user = User.create!
    get authenticate_products_url
    visit.reload
    assert_equal user, visit.user
  end

  def test_mask_ips
    with_options(mask_ips: true) do
      get products_url
      assert_equal "127.0.0.0", Ahoy::Visit.last.ip
    end
  end

  def test_skip_before_action
    get no_visit_products_url
    assert_equal 0, Ahoy::Visit.count
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

  def test_api_only
    with_options(api_only: true) do
      get list_products_url
      assert_equal 0, Ahoy::Visit.count
      assert_empty response.cookies
    end
  end

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
      assert_equal "8924a60c-5c50-5d80-b38d-e6c68fcd0958", visit.visit_token
      assert_equal "64dcde66-9659-5473-897e-5abd59f8b89f", visit.visitor_token
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
    exclude_method = lambda do |controller, request|
      request.parameters["exclude"] == "t"
    end
    with_options(exclude_method: exclude_method) do
      get products_url, params: {"exclude" => "t"}
      assert_equal 0, Ahoy::Visit.count
      get products_url
      assert_equal 1, Ahoy::Visit.count
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

  def test_geocode_true
    assert_enqueued_with(job: Ahoy::GeocodeV2Job, queue: "ahoy") do
      get products_url
    end
  end

  def test_geocode_false
    with_options(geocode: false) do
      get products_url
      assert_equal 0, enqueued_jobs.size
    end
  end

  def test_job_queue
    with_options(job_queue: :low_priority) do
      assert_enqueued_with(job: Ahoy::GeocodeV2Job, queue: "low_priority") do
        get products_url
      end
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

  def bot_user_agent
    "Mozilla/5.0 (compatible; DuckDuckBot-Https/1.1; https://duckduckgo.com/duckduckbot)"
  end
end
