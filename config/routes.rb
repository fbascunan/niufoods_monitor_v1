Rails.application.routes.draw do
  root "restaurants#index"
  resources :restaurants, only: [:index, :show]
  resources :devices, only: [:show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      post "devices/status", to: "devices#update_status"
      resources :restaurants, only: [:index]
    end
  end
end
