SharpApp::Application.routes.draw do
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'alerts#index'

  resources :service_codes

  resources :maint_codes

  resources :toner_codes

  resources :maint_counters

  resources :sheet_counts

  resources :jam_stats

  get "report/" => 'report#index', :as => :reports 
  get "report/alerts_graph"
  get "report/device_volume_graph"
  get "report/frequency"
  get "report/volume"
  get "report/jam_code_stats" => 'report#jam_code_stats', :as => :jam_code_stats_report
  get 'report/:id/jam_history/:code' => 'report#jam_history', :as => :jam_history_report
  get 'report/:id/full_cfs_history' => 'report#full_cfs_history', :as => :full_cfs_history_report
  get 'report/:id/full_maint_history' => 'report#full_maint_history', :as => :full_maint_history_report
  get 'report/:id/toner_history' => 'report#toner_history', :as => :toner_history_report
  get 'report/drum_dev_age', :as => :drum_dev_age_report
  get 'report/:id/full_jam_history' => 'report#full_jam_history', :as => :full_jam_history_report
  
  
  resources :print_volumes

  resources :summaries

  resources :counters do
    collection do
      get 'detail'
    end
  end

  resources :devices

  resources :clients

  get "about/me"

  get "about/search"

  resources :notify_controls do
    collection do
      get 'batch_edit'
      post 'batch_update'
    end
  end

  resources :alerts

#   resources :notify_controls do
#     collection do
#       get 'test'
#     end
#   end
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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
