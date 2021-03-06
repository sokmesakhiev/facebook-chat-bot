Rails.application.routes.draw do
  devise_for :users, path: '/', controllers: { omniauth_callbacks: 'auth/callbacks' }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  get 'privacy-policy' => 'privacy_policies#index'

  get 'webhook' => 'fbmessengers#get_webhook'
  post 'webhook' => 'fbmessengers#post_webhook'

  get 'oauth_callbacks' => 'oauth_callbacks#create'
  post 'oauth_callbacks' => 'oauth_callbacks#create'

  resource :home, only: :index
  resources :bots, only: [:index, :show, :create, :update] do
    member do
      post :import
      delete :delete_survey
      put :deactivate
      put :activate
      get :download
    end
  end

  resources :facebook_pages, only: :index

  resources :users, only: [:index, :create, :update] do
    member do
      put :deactivate
      put :activate
    end
  end

  # resolve session
  post ':controller(/:action(/:id(.:format)))'
  get ':controller(/:action(/:id(.:format)))'

  # match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  # match 'auth/failure', to: redirect('/'), via: [:get, :post]
  # match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  scope '/api', as: :api, module: :api do
    resources :bots, only: :update
  end

  require 'sidekiq/web'
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
  end if Rails.env.production?
  mount Sidekiq::Web, at: "/sidekiq"
end
