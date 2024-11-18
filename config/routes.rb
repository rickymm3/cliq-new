Rails.application.routes.draw do

  # Home page routes
  get 'home/index'
  root 'cliqs#index'  # Set the root route to 'home#index'

  # Devise routes for user authentication
  devise_for :users, controllers: { 
    registrations: 'users/registrations' 
  }

  # Resources for posts with a custom path 'p'
  resources :posts, path: 'p', only: [:show, :edit, :new, :update, :create, :index] do
    # Place the edit route first to prevent conflicts
    member do
      get 'edit', to: 'posts#edit'
    end

    # Route for posts with both id and slug - ensure it's after the edit route
    get ':slug', action: 'show', as: :id_slug_post
  end

  # Resources for cliqs with a custom path 'c'
  resources :cliqs, path: 'c' do
    # Custom route for showing all cliqs
    collection do
      get 'all', to: 'cliqs#all'
    end
    collection do
      post :search
    end
    resources :posts, only: [:new]  # New post route within a cliq
    resources :cliqs, only: [:show, :new, :create], controller: 'cliqs', path: ''  # Nested cliq routes
  end

  # Profile routes
  get 'profile' => 'profiles#show', as: :profile
  get 'profile/edit' => 'profiles#edit', as: :edit_profile
  patch 'profile' => 'profiles#update'

end
