require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../oauth_controller_test_helper'
require 'oauth/client/action_controller_request'

class OauthClientsController; def rescue_action(e) raise e end; end

class OauthClientsControllerIndexTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController
  
  def setup    
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end
  
  def test_should_show_index
    user = User.find_by_id(users(:ryan).id)
    tokens = user.tokens.find(:all, :conditions => 'oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
    do_login :ryan
    get :index
    assert @response.success?
    assert_template 'index'
    assert assigns(:client_applications)
    assert_equal user.client_applications, assigns(:client_applications)
    assert assigns(:tokens)
    assert_equal tokens, assigns(:tokens)
    assert_select 'div.intro_text', {:count => 1, :text => t(:oauth_index_applications_intro)}
    assert_select 'ul.client_application_list li', :count=> user.client_applications.count
    assert_select 'div.intro_text',  {:count => 1, :text => t(:oauth_index_token_intro)}
    assert_select 'ul.token_list li', :count=> tokens.count
    assert_select "input[type=hidden][value=#{tokens[0].token}]", 1
    assert_select "form input[type=submit][value=#{t(:link_delete_token)}]", tokens.count
  end
  
  def test_should_show_empty_index
    user = User.find_by_id(users(:user2).id)
    do_login :user2
    get :index
    assert @response.success?
    assert_template 'index'
    assert assigns(:client_applications)
    assert_equal assigns(:client_applications).count, 0
    assert assigns(:tokens)
    assert_equal assigns(:tokens).count, 0
    #assert_select 'div', t(:oauth_index_no_applications_intro)
    assert_select 'ul[class=client_application_list] li', :count=> 0
    assert_select 'div', {:count => 0, :text => t(:oauth_index_token_intro)}
    assert_select 'ul[class=token_list] li', :count=> 0
  end
  
  def should_not_show_index_not_logged_in
    get :index
    assert_login_redirect
  end
end

class OauthClientsControllerShowTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController
  
  def setup
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end
  
  def test_does_show
    @user = User.find_by_id(users(:ryan).id)
    assert_not_nil @user
    @client_application = @user.client_applications.find_by_id(client_applications(:app1).id)
    assert_not_nil @client_application
    do_login :ryan
    get :show, :id=>@client_application.id
    assert @response.success?
    assert_template 'show'
    assert assigns(:client_application)
    assert_equal client_applications(:app1).id, assigns(:client_application).id
    assert_select 'h1', t(:title_show_oauth, :name => client_applications(:app1).name)
    assert_select 'label', t(:input_oauth_consumer_key)
    assert_select 'code', @client_application.key
    assert_select 'label', t(:input_oauth_consumer_secret)
    assert_select 'code', @client_application.secret
    assert_select 'label', t(:input_oauth_consumer_request_token_url)
    assert_select 'code', 'http://' + @request.host_with_port + @client_application.oauth_server.request_token_path
    assert_select 'label', t(:input_oauth_consumer_access_token_url)
    assert_select 'code', 'http://' + @request.host_with_port + @client_application.oauth_server.access_token_path
    assert_select 'label', t(:input_oauth_consumer_authorize_url)
    assert_select 'code', 'http://' + @request.host_with_port + @client_application.oauth_server.authorize_path
    assert_select "a[href=#{edit_oauth_client_path(@client_application)}]", t(:link_edit)
    assert_select "a[href=#{oauth_clients_path}]", t(:link_back)
  end
  
  def test_does_not_show_id_missing
    do_login :ryan
    get :show
    assert_error_redirect :msg_not_authorized
  end
  
  def test_does_not_show_not_authorized
    do_login :ryan
    get :show, :id=>client_applications(:app2).id
    assert_error_redirect :msg_not_authorized
  end
  
  def test_does_not_show_not_logged_in
    get :show, :id=>client_applications(:app2).id
    assert_login_redirect
  end
  
end

class OauthClientsControllerNewTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController

  def setup
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end
  
  def test_should_show_new_form
    do_login :ryan
    get :new
    assert @response.success?
    assert_template 'new'
    assert assigns(:client_application)
    assert_nil assigns(:client_application).id
    assert_select "input[type=submit][value=#{t(:btn_register)}]", :count => 1
  end
  
  def test_should_not_show_new_form_not_logged_in
    get :new
    assert_login_redirect
  end
  
end
 
class OauthClientsControllerEditTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController
  
  def setup
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end
  
  def test_does_show_edit
    do_login :ryan
    get :edit, :id=>client_applications(:app1).id
    assert @response.success?
    assert_template 'edit'
    assert assigns(:client_application)
    assert_equal client_applications(:app1).id, assigns(:client_application).id
    assert_select 'h1', t(:title_edit_oauth)
    assert_select "input[type=text][value=#{client_applications(:app1).name}]", :count => 1
    assert_select "input[type=text][value=#{client_applications(:app1).url}]", :count => 1
    assert_select "input[type=submit][value=#{t(:btn_save)}]", :count => 1
    assert_select 'a', t(:link_show)
    assert_select 'a', t(:link_back)
end
  
  def test_does_not_edit_id_missing
    do_login :ryan
    get :edit
    assert_error_redirect :msg_not_authorized
  end
  
  def test_does_not_edit_not_authorized
    do_login :ryan
    get :edit, :id=>client_applications(:app2).id
    assert_error_redirect :msg_not_authorized
  end
  
  def test_does_not_edit_not_logged_in
    get :edit, :id=>client_applications(:app2).id
    assert_login_redirect
  end
  
end

class OauthClientsControllerCreateTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController
  
  def setup
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new    
  end
  
  def test_should_create_client_application
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_login :ryan
    post :create,:client_application=>{:name=>'my site', :url=>'http://testclient.app'}
    assert_equal app_count + 1, @user.client_applications.count
    assert assigns(:client_application)
    assert assigns(:client_application).id
    assert_response :redirect
    assert_redirected_to(:action => "show", :id => assigns(:client_application).id)
  end
  
  def test_should_not_create_client_application_url_missing
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_login :ryan
    post :create,:client_application=>{:name=>'my site'}
    assert_equal app_count, @user.client_applications.count
    assert_template('new')
    assert assigns(:client_application)
    assert_nil assigns(:client_application).id
    assert_equal flash[:error], t(:msg_oauth_client_not_saved)
  end

  def test_should_not_create_client_application_name_missing
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_login :ryan
    post :create,:client_application=>{:url=>'http://testclient.app'}
    assert_equal app_count, @user.client_applications.count
    assert_template('new')
    assert assigns(:client_application)
    assert_nil assigns(:client_application).id
    assert_equal flash[:error], t(:msg_oauth_client_not_saved)
  end

  def test_should_not_create_client_application_not_logged_in
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    post :create,:client_application=>{:name=>'my site', :url=>'http://testclient.app'}
    assert_equal app_count, @user.client_applications.count
    assert_login_redirect
  end
end
 
class OauthClientsControllerDestroyTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController
  
  def setup
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def do_delete
    delete :destroy,:id=>client_applications(:app1).id
  end
    
  def test_should_destroy_client_applications
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_login :ryan
    do_delete
    assert_equal app_count - 1, @user.client_applications.count
    assert_equal flash[:notice], t(:msg_oauth_client_deleted)
    assert_redirected_to :action=>"index"
  end
    
  def test_should_not_destroy_id_missing
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_login :ryan
    delete :destroy
    assert_equal app_count, @user.client_applications.count
    assert_error_redirect :msg_not_authorized
  end
    
  def test_should_not_destroy_not_authorized
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_login :user1
    do_delete
    assert_equal app_count, @user.client_applications.count
    assert_error_redirect :msg_not_authorized
  end
    
  def test_should_not_destroy_not_logged_in
    @user = User.find_by_id(users(:ryan).id)
    app_count = @user.client_applications.count
    do_delete
    assert_equal app_count, @user.client_applications.count
    assert_login_redirect
  end
    
end

class OauthClientsControllerUpdateTest < ActionController::TestCase
  include OAuthControllerTestHelper
  tests OauthClientsController

  def setup
    @controller = OauthClientsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def do_update
    put :update, :id => client_applications(:app1).id, :client_application => {:name => 'my site'}
  end

  def test_should_edit_client_application
    do_login :ryan
    do_update
    assert_response :redirect
    assert_redirected_to :action => "show", :id => client_applications(:app1).id
    assert assigns(:client_application)
    assert_equal assigns(:client_application).id, client_applications(:app1).id
    assert_equal User.find_by_id(users(:ryan).id).client_applications.find_by_id(client_applications(:app1).id).name, 'my site'
    assert_equal flash[:notice], t(:msg_oauth_client_updated)
  end
  
  def test_should_not_edit_client_application_not_authorized
    do_login :user1
    do_update
    assert_error_redirect :msg_not_authorized
    assert_equal User.find_by_id(users(:ryan).id).client_applications.find_by_id(client_applications(:app1).id).name, client_applications(:app1).name
  end
  
  def test_should_not_edit_client_application_not_logged_in
    do_update
    assert_login_redirect
    assert_equal User.find_by_id(users(:ryan).id).client_applications.find_by_id(client_applications(:app1).id).name, client_applications(:app1).name
  end
  
  def test_should_not_edit_invalid_input
    do_login :ryan
    put :update, :id => client_applications(:app1).id, :client_application => {:name => '', :url => 'invalid_url'}
    assert_template('edit')
    assert assigns(:client_application)
    assert_equal assigns(:client_application).id, client_applications(:app1).id
    assert_equal User.find_by_id(users(:ryan).id).client_applications.find_by_id(client_applications(:app1).id).name, client_applications(:app1).name
    assert_select 'h1', t(:title_edit_oauth)
    assert_select 'div.error_msg', :count => 1, :text => assigns(:client_application).errors.on_s(:name)
    assert_select 'div.error_msg', :count => 1, :text => assigns(:client_application).errors.on_s(:url)
    assert_select 'input[type=text][value=]', :count => 1
    assert_select 'input[type=text][value=invalid_url]', :count => 1
    assert_select "input[type=submit][value=#{t(:btn_save)}]", :count => 1
    assert_select 'a', t(:link_show)
    assert_select 'a', t(:link_back)
  end
end
