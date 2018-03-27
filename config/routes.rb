Rails.application.routes.draw do
  get 'home/show'

  get 'webhook' => 'fbmessengers#get_webhook'
  post 'webhook' => 'fbmessengers#post_webhook'
  get 'oauthcallback' => 'fbmessengers#oauthcallback'

  resources :sessions, only: [:create, :destroy]
  resource :home, only: [:show]

  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  root to: "home#show"
end
