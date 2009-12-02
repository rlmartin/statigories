ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "general_page"

  # See how all your routes lay out with "rake routes"

	# Login routes
  map.login 'login', :controller => "sessions", :action => "create", :conditions => { :method => :post }
  map.login 'login', :controller => "sessions", :action => "new", :conditions => { :method => :get }
  map.logout 'logout', :controller => "sessions", :action => "destroy"

	# User routes
	map.new_user 'signup', :controller => "users", :action => "create", :conditions => { :method => :post }
	map.new_user 'signup', :controller => "users", :action => "new", :conditions => { :method => :get }
	map.forgot_password 'forgot_password', :controller => "users", :action => "process_forgot_password", :conditions => { :method => :post }
	map.forgot_password 'forgot_password', :controller => "users", :action => "forgot_password", :conditions => { :method => :get }
	map.resend_verify 'resend_verify', :controller => "users", :action => "process_resend_verify", :conditions => { :method => :post }
	map.resend_verify 'resend_verify', :controller => "users", :action => "resend_verify", :conditions => { :method => :get }
	map.verify_check 'verify', :controller => "users", :action => "verify_check"
	map.verify_user 'user/:username/verify', :controller => "users", :action => "verify"
	map.edit_user 'user/:username/edit', :controller => "users", :action => "edit", :conditions => { :method => :get }
	map.reset_password 'user/:username/reset_password', :controller => "users", :action => "process_reset_password", :conditions => { :method => :post }
	map.reset_password 'user/:username/reset_password', :controller => "users", :action => "reset_password", :conditions => { :method => :get }
	map.user 'user/:username', :controller => "users", :action => "update", :conditions => { :method => :post }
	map.user_availability 'user', :controller => "users", :action => "show", :conditions => { :method => :get }
	map.user 'user/:username', :controller => "users", :action => "show", :conditions => { :method => :get }
	map.user 'user/:username', :controller => "users", :action => "destroy", :conditions => { :method => :delete }

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end