require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def test_should_show_login
    get :new
    assert_response :success
    assert_template :new
  end

  def test_should_login
    do_login
    assert assigns(:current_user)
    assert_redirected_to '/'
    assert_not_nil session[:user_id]
    assert session[:logged_in]
  end

  def test_should_not_login_bad_email
    post :create, :email => 'xx' + users(:ryan).email, :password => 'pwd'
    assert ! assigns(:current_user)
    assert_not_nil flash[:error]
    assert_equal flash[:error], I18n.t(:msg_invalid_login)
    assert_response :success
    assert_template :new
    assert_nil session[:user_id]
    assert ! session[:logged_in]
  end

  def test_should_not_login_bad_password
    post :create, :email => users(:ryan).email, :password => 'pwd1'
    assert ! assigns(:current_user)
    assert_not_nil flash[:error]
    assert_equal flash[:error], I18n.t(:msg_invalid_login)
    assert_response :success
    assert_template :new
    assert_nil session[:user_id]
    assert ! session[:logged_in]
  end

  def test_should_not_show_login_when_logged_in
    do_login
    get :new
    assert_redirected_to '/'
  end

  def test_should_logout
    do_login
    assert assigns(:current_user)
    assert_redirected_to '/'
    assert_not_nil session[:user_id]
    assert session[:logged_in]
    get :destroy
    assert ! assigns(:current_user)
    assert_response :success
    assert_template :destroy
    assert ! session[:logged_in]
		assert_nil session[:user_id]
		assert_nil session[:username]
		assert_nil session[:name]
		assert_nil session[:logged_in]
		assert_nil session[:_me]
		assert_nil cookies[:user_id]
  end

end
