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
    assert :success

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
    visit =
      Ahoy::Visit.create!(
        visit_token: random_token,
        visitor_token: random_token,
        started_at: Time.current
      )

    name = "Test"
    event_params = {
      visit_token: visit.visit_token,
      visitor_token: visit.visitor_token,
      events_json: [
        {
          id: random_token,
          name: name,
          properties: {},
          time: Time.current.iso8601
        }
      ].to_json
    }
    post ahoy_engine.events_url, params: event_params
    assert :success

    assert_equal 1, Ahoy::Event.count

    event = Ahoy::Event.last
    assert_equal visit, event.visit
    assert_equal name, event.name
  end

  def random_token
    SecureRandom.uuid
  end
end
