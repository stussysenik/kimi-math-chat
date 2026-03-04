Rails.application.routes.draw do
  root "conversations#index"

  resources :conversations, only: %i[index show create destroy] do
    member do
      patch :update_model
    end
    resources :messages, only: :create
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
