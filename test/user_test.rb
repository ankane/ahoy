require_relative "test_helper"

class UserTest < ActionDispatch::IntegrationTest
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

  def test_authenticate
    get products_url
    visit = Ahoy::Visit.last
    assert_nil visit.user
    user = User.create!
    get authenticate_products_url
    visit.reload
    assert_equal user, visit.user
  end
end
