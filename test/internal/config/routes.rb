Rails.application.routes.draw do
  resources :products, only: [:index, :create] do
    get :list, on: :collection
    get :authenticate, on: :collection
    get :no_visit, on: :collection
  end
end
