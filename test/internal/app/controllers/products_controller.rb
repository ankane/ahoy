class ProductsController < ActionController::Base
  def index
    ahoy.track "Viewed products"
    render json: {}
  end
end
