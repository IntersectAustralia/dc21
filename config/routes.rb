Dc21app::Application.routes.draw do

  resources :packages do
    member do
      get :publish
    end
  end

  resources :cart_items, :only => [:index, :create, :destroy]  do
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
      #get :admin
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
    end
  end

  namespace :admin do
    resource :config, :controller => "config"
  end

  resource :pages do
    get :home
    get :about
  end

  resources :data_files do
    member do
      get :download
    end
    collection do
      get :download_selected
      put :bulk_update
      post :search
      post :api_create
      post :api_search, :defaults => { :format => 'json' }
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
# SystemConfiguration.instance.level1_plural.gsub(/\s+/, "_").downcase.to_sym

  root :to => "pages#home"

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.is_admin?
  end

  constraints resque_constraint do
    mount Resque::Server, :at => "/resque"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
