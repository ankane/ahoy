require_relative "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include Rails.application.routes.mounted_helpers

  def setup
    Ahoy::Visit.delete_all
    Ahoy::Event.delete_all
  end

  def test_works
    visit_token = random_token
    visitor_token = random_token

    post ahoy_engine.visits_url, params: {visit_token: visit_token, visitor_token: visitor_token}
    assert :success

    assert_equal 1, Ahoy::Visit.count

    visit = Ahoy::Visit.last
    assert_equal visit_token, visit.visit_token
    assert_equal visitor_token, visit.visitor_token
  end

  def random_token
    SecureRandom.uuid
  end
end
