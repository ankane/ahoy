Rails.application.routes.draw do
  resources :products, only: [:index, :create] do
    get :list, on: :collection
    get :authenticate, on: :collection
  end
end
