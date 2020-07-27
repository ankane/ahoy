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

  def test_time
    # todo
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
      assert_response 413
      assert_equal "Payload too large\n", response.body
    end
  end

  def random_visit
    Ahoy::Visit.create!(
      visit_token: random_token,
      visitor_token: random_token,
      started_at: Time.current.round # so it's not ahead of event
    )
  end

  def random_token
    SecureRandom.uuid
  end
end
