Rails.application.routes.draw do
  mount Ahoy::Engine => "/ahoy"
end

Ahoy::Engine.routes.draw do
  resources :visits, only: [:create]
end
