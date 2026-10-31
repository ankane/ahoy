require_relative "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include Rails.application.routes.mounted_helpers

  def setup
    Ahoy::Visit.delete_all
    Ahoy::Event.delete_all
  end

  def test_visit
    visit_token = random_token
    visitor_token = random_token

    post ahoy_engine.visits_url, params: {visit_token: visit_token, visitor_token: visitor_token}
    assert_response :success

    body = JSON.parse(response.body)
    expected_body = {
      "visit_token" => visit_token,
      "visitor_token" => visitor_token,
      "visit_id" => visit_token,
      "visitor_id" => visitor_token
    }
    assert_equal expected_body, body

    assert_equal 1, Ahoy::Visit.count

    visit = Ahoy::Visit.last
    assert_equal visit_token, visit.visit_token
    assert_equal visitor_token, visit.visitor_token
  end

  def test_event
    visit = random_visit

    name = "Test"
    time = Time.current.round
    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      events_json: [
        {
          id: random_token,
          name: name,
          properties: {},
          time: time
        }
      ].to_json
    }
    post ahoy_engine.events_url, params: event_params
    assert_response :success

    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal visit, event.visit
    assert_equal name, event.name
    assert_equal time, event.time
  end

  def test_event_params
    visit = random_visit

    name = "Test"
    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      name: name,
      properties: {}
    }
    post ahoy_engine.events_url, params: event_params
    assert_response :success

    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal visit, event.visit
    assert_equal name, event.name
  end

  def test_event_time
    freeze_time

    visit = random_visit(started_at: 1.hour.ago)
    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      events_json: [
        {
          id: random_token,
          name: "Test",
          properties: {},
          time: 2.minutes.ago
        }
      ].to_json
    }

    post ahoy_engine.events_url, params: event_params
    assert_response :success

    event = Ahoy::Event.last
    assert_equal Time.current, event.time
  end

  def test_event_bad_json
    visit = random_visit

    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      events_json: "bad"
    }
    post ahoy_engine.events_url, params: event_params
    assert_response :success

    assert_equal 0, Ahoy::Event.count
  end

  def test_event_bad_array
    visit = random_visit

    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      events_json: "null"
    }
    post ahoy_engine.events_url, params: event_params
    assert_response :bad_request
    assert_equal "Invalid parameters\n", response.body
  end

  def test_event_bad_element
    visit = random_visit

    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      events_json: "[null]"
    }
    post ahoy_engine.events_url, params: event_params
    assert_response :bad_request
    assert_equal "Invalid parameters\n", response.body
  end

  def test_before_action
    post ahoy_engine.visits_url, params: {visit_token: random_token, visitor_token: random_token}
    assert_nil controller.ran_before_action
  end

  def test_renew_cookies
    post ahoy_engine.visits_url, params: {visit_token: random_token, visitor_token: random_token, js: true}
    assert_equal ["ahoy_visit"], response.cookies.keys
  end

  def test_max_content_length
    with_options(max_content_length: 1) do
      post ahoy_engine.visits_url, params: {visit_token: random_token, visitor_token: random_token}
      assert_response :content_too_large
      assert_equal "Payload too large\n", response.body
    end
  end

  def test_max_events_per_request
    visit = random_visit
    events = 10.times.map { random_event }

    with_options(max_events_per_request: 5) do
      event_params = {
        visit_token: visit.visit_token,
        visitor_token: visit.visitor_token,
        events_json: events.to_json
      }
      post ahoy_engine.events_url, params: event_params
      assert_response :success

      assert_equal 5, Ahoy::Event.count
    end
  end

  def test_visit_utm_params_from_landing_page
    landing_page = "http://www.example.com/products?utm_source=test-source&utm_medium=test-medium&utm_term=test-term&utm_content=test-content&utm_campaign=test-campaign"
    post ahoy_engine.visits_url, params: {visit_token: random_token, visitor_token: random_token, landing_page: landing_page}
    assert_response :success

    visit = Ahoy::Visit.last
    assert_equal "test-source", visit.utm_source
    assert_equal "test-medium", visit.utm_medium
    assert_equal "test-term", visit.utm_term
    assert_equal "test-content", visit.utm_content
    assert_equal "test-campaign", visit.utm_campaign
  end

  def test_visit_utm_params_from_landing_page_decoding
    landing_page = "http://www.example.com/?utm_source=first&utm_source=second&utm_medium=&utm_term=%E6%98%A5&utm_campaign=spring+sale&q=100%"
    post ahoy_engine.visits_url, params: {visit_token: random_token, visitor_token: random_token, landing_page: landing_page}
    assert_response :success

    visit = Ahoy::Visit.last
    assert_equal "first", visit.utm_source
    assert_equal "", visit.utm_medium
    assert_equal "春", visit.utm_term
    assert_nil visit.utm_content
    assert_equal "spring sale", visit.utm_campaign
  end

  def test_visit_utm_params_from_landing_page_invalid_utf8
    landing_page = "http://www.example.com/?utm_source=%FF&utm_medium=test-medium"
    post ahoy_engine.visits_url, params: {visit_token: random_token, visitor_token: random_token, landing_page: landing_page}
    assert_response :success

    visit = Ahoy::Visit.last
    assert visit.utm_source.valid_encoding?
    assert_equal "test-medium", visit.utm_medium
  end

  def test_missing_params
    post ahoy_engine.events_url
    assert_response :bad_request
    assert_equal "Missing required parameters\n", response.body
  end

  def random_visit(started_at: nil)
    Ahoy::Visit.create!(
      visit_token: random_token,
      visitor_token: random_token,
      started_at: started_at || Time.current.round # so it's not ahead of event
    )
  end

  def random_event
    {
      id: random_token,
      name: "Test",
      properties: {},
      time: Time.current.round
    }
  end

  def random_token
    SecureRandom.uuid
  end
end
