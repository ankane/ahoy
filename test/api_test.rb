require_relative "test_helper"

class ApiTest < ActionDispatch::IntegrationTest
  include Rails.application.routes.mounted_helpers

  def setup
    Ahoy::Visit.delete_all
    Ahoy::Event.delete_all
  end

  def test_works
    post ahoy_engine.visits_url
    assert :success
  end
end
