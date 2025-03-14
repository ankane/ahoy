Rails.application.routes.draw do
  resources :products, only: [:index, :create] do
    get :list, on: :collection
    get :authenticate, on: :collection
    get :no_visit, on: :collection
  end

  if Rails::VERSION::STRING.to_f >= 7.1
    get "up" => "rails/health#show", as: :rails_health_check
  end
end
