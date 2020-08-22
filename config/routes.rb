Rails.application.routes.draw do
  resource :session, only: %w[new create destroy]
  resources :users
  resources :recipes do
    resources :tsukurepos, only: %w[new create destroy]
  end
  resources :images, only: %w[show]

  root to: 'top#index'
end
