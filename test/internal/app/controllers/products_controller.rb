class ProductsController < ApplicationController
  skip_before_action :track_ahoy_visit, only: [:no_visit]

  def index
    ahoy.track "Viewed products"
    head :ok
  end

  def list
    head :ok
  end

  def create
    Product.create!
    head :ok
  end

  def authenticate
    ahoy.authenticate(User.last)
    head :ok
  end

  def no_visit
    head :ok
  end

  private

  def current_user
    @current_user ||= User.last
  end

  def true_user
    @true_user ||= User.create!(name: "True User")
  end
end
