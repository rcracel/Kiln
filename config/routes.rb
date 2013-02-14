Kiln::Application.routes.draw do
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
  root :to => 'welcome#index'

  match '/status' => 'system#status', :as => :system_status

  match '/signup' => 'users#signup', :as => :signup, :via => :get
  match '/signup' => 'users#do_signup', :as => :do_signup, :via => :post

  match '/forgot' => 'users#forgot_password', :as => :forgot_password, :via => :get  
  match '/forgot' => 'users#do_forgot_password', :as => :do_forgot_password, :via => :post

  match '/reset'  => 'users#reset_password', :as => :reset_password, :via => :get
  match '/reset'  => 'users#do_reset_password', :as => :do_reset_password, :via => :post

  match '/login' => 'sessions#new', :as => :login

  match '/logout' => 'sessions#destroy', :as => :logout

  match '/authenticate' => 'sessions#create', :as => :authenticate

  match '/account' => 'account#edit',    :as => :user_account, :via => :get
  match '/account' => 'account#update',  :as => :user_account, :via => :put

  match '/dashboard' => 'welcome#index', :as => :dashboard

  match '/admin' => 'admin#home', :as => :admin_home, :via => :get
  match '/admin/info' => 'admin#info', :as => :admin_info

  # User Groups .............

  match '/admin/groups' => 'admin#groups', :as => :group_management, :via => :get
  match '/admin/groups' => 'admin#do_create_group', :as => :do_create_group, :via => :post

  match '/admin/group/:id/delete' => 'admin#delete_group', :as => :delete_group, :via => :get
  match '/admin/group/:id/delete' => 'admin#do_delete_group', :as => :do_delete_group, :via => :delete

  match '/admin/group/:id/users' => 'admin#group_users', :as => :manage_group_users, :via => :get
  match '/admin/group/:id/users' => 'admin#update_group_users', :as => :update_group_users, :via => :post

  # Applications .............

  match '/admin/apps' => 'admin#apps', :as => :application_management, :via => :get

  match '/admin/app/:id/delete' => 'admin#confirm_delete_app', :as => :delete_app, :via => :get
  match '/admin/app/:id/delete' => 'admin#do_delete_app', :as => :do_delete_app, :via => :delete

  match '/admin/app/:id/reassign' => 'admin#confirm_reassign_app', :as => :reassign_app, :via => :get
  match '/admin/app/:id/reassign' => 'admin#do_reassign_app', :as => :do_reassign_app, :via => :put

  # Users ..............

  match '/admin/users' => 'admin#users', :as => :user_management, :via => :get

  # Events ..............

  match '/admin/events/truncate' => 'admin#truncate_events', :as => :truncate_events_all_apps, :via => :get
  match '/admin/events/confirm_truncate' => 'admin#confirm_truncate_events', :as => :confirm_truncate_events_all_apps, :via => :post
  match '/admin/events/truncate' => 'admin#do_truncate_events', :as => :do_truncate_events_all_apps, :via => :post


  match '/admin/user/:id/confirm_delete' => 'admin#confirm_delete_user', :as => :delete_user, :via => :get
  match '/admin/user/:id/delete' => 'admin#do_delete_user', :as => :do_delete_user, :via => :delete
  match '/admin/user/:id/promote' => 'admin#promote_user', :as => :promote_user, :via => :get
  match '/admin/user/:id/demote' => 'admin#demote_user', :as => :demote_user, :via => :get
  match '/admin/user/:id/authorize' => 'admin#authorize_user', :as => :authorize_user, :via => :get
  match '/admin/user/:id/deauthorize' => 'admin#deauthorize_user', :as => :deauthorize_user, :via => :get

  match '/admin/user/new' => 'admin#create_user', :as => :create_user, :via => :get
  match '/admin/user/new' => 'admin#do_create_user', :as => :do_create_user, :via => :post

  match '/events' => 'events#index', :as => :events

  match '/apps' => 'applications#index', :as => :applications, :via => :get
  match '/apps' => 'applications#create', :as => :create_application, :via => :post
  match '/apps/:id/users' => 'applications#authorized_users', :as => :application_authorized_users, :via => :get
  match '/apps/:id/users' => 'applications#update_authorized_users', :as => :application_update_authorized_users, :via => :post

  match '/docs' => 'documentation#index', :as => :documentation

  namespace :api do

    match '/events/publish' => 'events#publish', :as => :event_publisher



    # These require a logged in user in the session

    match '/internal/events/tail' => 'internal#events_tail', :as => :internal_events_tail
    match '/internal/events/head' => 'internal#events_head', :as => :internal_events_head

    match '/internal/events/:id/stacktrace' => 'internal#event_stacktrace', :as => :internal_event_stacktrace    
    match '/internal/users/search' => 'internal#user_list', :as => :internal_user_list

  end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
