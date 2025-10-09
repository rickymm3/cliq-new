# config/routes.rb
Rails.application.routes.draw do
  resources :replies

  get 'home/index'
  root 'cliqs#show'

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  resources :posts, path: 'p', only: [:show, :edit, :new, :update, :create, :index] do
    member do
      get 'edit', to: 'posts#edit'
      patch :soft_delete 
    end
    resources :replies, only: [:create, :destroy, :new]
    get ':slug', action: 'show', as: :id_slug_post
  end

  resources :subscriptions, only: [:create, :destroy] do
    member do
      get :confirm
      get :row
      patch :toggle   # ← enable/disable without unsubscribing

    end
  end

  get "subscribed", to: "feeds#subscribed", as: :subscribed


  resources :cliqs, path: 'c' do
    collection do
      get 'all', to: 'cliqs#all'
      post :search
    end
    
    resources :posts, only: [:new]
    resources :cliqs, only: [:show, :new, :create], controller: 'cliqs', path: ''
  end

  # Resourceful routes for profiles.
  # With the Profile model’s to_param override, profile_path(@profile) will use the username.
  resources :profiles, only: [:show, :edit, :update] do
    member do
      get :posts
      get :replies
      get :articles
      get :subscriptions
    end
  end

  # Routes for following users using the FollowedUser model.
  post 'follow/:user_id', to: 'followed_users#create', as: :follow_user
  delete 'unfollow/:user_id', to: 'followed_users#destroy', as: :unfollow_user
  resources :followed_users, only: [:index]

  # Notifications routes.
  resources :notifications, only: [:index, :update] do
    collection do
      patch :mark_all_read
    end
  end
end
