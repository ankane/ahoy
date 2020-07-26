Rails.application.routes.draw do
  resources :products, only: [:index, :create] do
    get :list, on: :collection
  end
end
