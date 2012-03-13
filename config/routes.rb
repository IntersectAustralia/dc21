Dc21app::Application.routes.draw do

  devise_for :users, :controllers => {:registrations => "user_registers", :passwords => "user_passwords"} do
    get "/users/profile", :to => "user_registers#profile" #page which gives options to edit details or change password
    get "/users/edit_password", :to => "user_registers#edit_password" #allow users to edit their own password
    put "/users/update_password", :to => "user_registers#update_password" #allow users to edit their own password
    get "/users/get_authentication_token", :to => "user_registers#get_authentication_token"
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
      get :build_download
      get :custom_download
      post :verify_upload

      get :list_for_post_processing
      post :post_process
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
      get :second_level
      get :third_level
    end
  end

  resources :facilities, :except => [:destroy] do
    resources :experiments, :except => [:destroy] do
      resources :experiment_parameters, :except => [:show, :index]
    end
  end

  root :to => "pages#home"

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
