not Dc21app::Application.routes.draw do

  mount Bootsy::Engine => '/bootsy', as: 'bootsy'

  resources :packages do
    member do
      get :publish
    end
  end

  resources :cart_items, :only => [:index, :create, :destroy] do
    collection do
      get :add_all
      get :add_recent
      post :add_single
      get :destroy_all
    end
  end

  resources :carts

  devise_for :users, :controllers => {:registrations => "user_registers", :passwords => "user_passwords"} do
    get "/users/profile", :to => "user_registers#profile" #page which gives options to edit details or change password
    get "/users/edit_password", :to => "user_registers#edit_password" #allow users to edit their own password
    put "/users/update_password", :to => "user_registers#update_password" #allow users to edit their own password
    put "/users/generate_token", :to => "user_registers#generate_token" #allow users to generate an API token
    delete "/users/delete_token", :to => "user_registers#delete_token" #allow users to delete their API token
  end

  get "/data_files/search" => "data_files#index" #to stop weird errors when visiting via get
  get "/column_mappings/render_field" => "column_mappings#render_field"

  resources :resque, :only => [] do
    collection do
      get :landing
    end
  end

  resources :users, :only => [:show] do
    collection do
      get :access_requests
      get :index
    end

    member do
      put :reject
      put :reject_as_spam
      put :deactivate
      put :activate
      get :edit_role
      put :update_role
      get :edit_approval
      put :approve
      put :add_access_group_to
      put :remove_access_group_from
    end
  end

  namespace :admin do
    resource :config, :controller => "config"

    resources :access_groups, :controller => "access_groups" do
      member do
        put :activate
        put :deactivate
      end
    end

    resource :dashboard, :controller => "dashboard"
  end

  resource :pages do
    get :home
    get :about
  end

  resources :data_files do
    member do
      get :download
      get :process_metadata_extraction
    end
    collection do
      get :download_selected
      put :bulk_update
      post :search
      post :api_create
      post :api_search, :defaults => {:format => 'json'}
      get :clear
    end
  end

  resources :column_mappings do
    member do
      get :map
      post :connect
    end
  end

  resources :for_codes, :only => [] do
    collection do
      get :top_level
      get :second_level
      get :third_level
      get :server_status
    end
  end

  resources :facilities, :path => :org_level1, :except => [:destroy] do
    resources :experiments, :path => :org_level2, :except => [:destroy] do
      resources :experiment_parameters, :except => [:show, :index]
    end
  end

  root :to => "pages#home"

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.is_admin?
  end

  constraints resque_constraint do
    mount Resque::Server, :at => "/resque"
  end
end
