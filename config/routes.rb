StatigoriesCom::Application.routes.draw do
  resources :oauth_clients
  match '/oauth_clients/:action(/:id)', :to => 'oauth_clients'

  match '/oauth/test_request', :to => 'oauth#test_request', :as => :test_request
  match '/oauth/access_token', :to => 'oauth#access_token', :as => :access_token
  match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
  match '/oauth/authorize', :to => 'oauth#authorize', :as => :authorize
  match '/oauth/revoke', :to => 'oauth#revoke'
  match '/oauth', :to => 'oauth#index', :as => :oauth

  match '/oauthorized/:action', :to => 'oauthorized'

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
  # root :to => "welcome#index"
  root :to => 'general_page#index'

  # See how all your routes lay out with "rake routes"

  # General pages
  match 'error', :to => 'general_page#error', :as => :error
  match 'javascripts/js_vars', :to => 'general_page#js_vars', :as => :js_vars

	# Login routes
  post 'login', :to => 'sessions#create', :as => :login
  get 'login', :to => 'sessions#new', :as => :login
  match 'logout', :to => 'sessions#destroy',:as => :logout

	# User routes
	post 'signup', :to => 'users#create', :as => :new_user
	get 'signup', :to => 'users#new', :as => :new_user
	post 'forgot_password', :to => 'users#process_forgot_password', :as => :forgot_password
	get 'forgot_password', :to => 'users#forgot_password', :as => :forgot_password
	post 'resend_verify', :to => 'users#process_resend_verify', :as => :resend_verify
	get 'resend_verify', :to => 'users#resend_verify', :as => :resend_verify
	match 'verify', :to => 'users#verify_check', :as => :verify_check
	match 'user/:username/verify', :to => 'users#verify', :as => :verify_user
	get 'user/:username/edit', :to => 'users#edit', :as => :edit_user
	post 'user/:username/reset_password', :to => 'users#process_reset_password', :as => :reset_password
	get 'user/:username/reset_password', :to => 'users#reset_password', :as => :reset_password
	post 'user(/:username)', :to => 'users#update', :as => :user
	get 'user+', :to => 'users#exists', :as => :user_availability
	get 'user/:username', :to => 'users#show', :as => :user
	delete 'user(/:username)', :to => 'users#destroy', :as => :user
	get 'users(/limit/:limit)', :to => 'users#search', :as => :users
	get 'users/search', :to => 'users#show_search', :as => :user_search
	post 'users/search', :to => 'users#search', :as => :user_search

  # Friend routes
  get 'user/:username/friends', :to => 'friendships#show', :as => :user_friends
  post 'user/:username/friend(/:friend)', :to => 'friendships#create', :as => :user_add_friend
  delete 'user/:username/friend(/:friend)', :to => 'friendships#destroy', :as => :user_remove_friend
  match 'user/:username/block_friend(/:friend)', :to => 'friendships#block', :as => :user_block_friend
  match 'user/:username/ignore_friend(/:friend)', :to => 'friendships#ignore', :as => :user_ignore_friend

  # Group routes
  get 'user/:username/groups', :to => 'groups#show_all', :as => :user_groups
  match 'user/:username/groups_add_to', :to => 'groups#form_add_to', :as => :user_groups_form_add_to
  post 'user/:username/group(/:group_name)', :to => 'groups#create', :as => :user_edit_group
  delete 'user/:username/group(/:group_name)', :to => 'groups#destroy', :as => :user_remove_group
  get 'user/:username/group(/:group_name)', :to => 'groups#show', :as => :user_group
  post 'user/:username/group_member', :to => 'group_memberships#create', :as => :user_group_add_member_dynamic
  post 'user/:username/group/:group_name/member/:friend', :to => 'group_memberships#create', :as => :user_group_add_member
  delete 'user/:username/group_member', :to => 'group_memberships#destroy', :as => :user_group_remove_member_dynamic
  delete 'user/:username/group/:group_name/member/:friend', :to => 'group_memberships#destroy', :as => :user_group_remove_member

  # Log Entry routes
  get 'user/:username/log/new', :to => 'log_entries#new', :as => :user_new_log
  match 'user/:username/log/quick(/*entry)', :to => 'log_entries#quick_add', :as => :log_entry_quick_add
  get 'user/:username/log/:index', :to => 'log_entries#show', :as => :user_log
  post 'user/:username/log/:index', :to => 'log_entries#edit', :as => :user_edit_log
  post 'user/:username/log/:index/label(/:label)', :to => 'log_entries#edit_label', :as => :user_edit_log_label
  delete 'user/:username/log/:index', :to => 'log_entries#destroy', :as => :user_delete_log
  post 'user/:username/log', :to => 'log_entries#create', :as => :user_create_log
  get 'user/:username/logs(/:num(/:start))', :to => 'log_entries#show_all', :as => :user_show_logs
  get 'log_entry_item_input(/:id)', :to => 'log_entry_items#input', :as => :log_entry_item_input

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
