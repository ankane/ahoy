class ProductsController < ActionController::Base
  def index
    ahoy.track "Viewed products"
    head :ok
  end

  def create
    Product.create!
    head :ok
  end
end
