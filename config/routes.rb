Rails.application.routes.draw do
  mount Ahoy::Engine => Ahoy.engine_path if Ahoy.api
end

Ahoy::Engine.routes.draw do
  scope module: "ahoy" do
    resources :visits, path: Ahoy.visits_path, only: [:create]
    resources :events, path: Ahoy.events_path, only: [:create]
  end
end
