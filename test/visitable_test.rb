require_relative "test_helper"

class VisitableTest < ActionDispatch::IntegrationTest
  def test_visitable
    post products_url
    visit = Ahoy::Visit.last
    assert_equal visit, Product.last.ahoy_visit
  end
end
