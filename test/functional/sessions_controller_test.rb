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
    log_count = EventLog.find(:all).count
    do_login
    assert assigns(:current_user)
    assert_redirected_to '/'
    assert_not_nil session[:user_id]
    assert session[:logged_in]
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::LOGIN
    get :destroy
    assert_equal log_count + 2, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::LOGOUT
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

  def test_should_not_allow_login_with_cookie
    do_login_with_remember
    assert_not_nil cookies['user_id']
    session.clear
    @request.cookies['user_id'] = CGI.unescape(cookies['user_id'])
    get :new
    assert_redirected_to '/'
  end

  def test_should_log_login_event
    log_count = EventLog.find(:all).count
    do_login
    assert_equal log_count + 1, EventLog.find(:all).count
  end

  def test_should_log_login_event_only_once
    log_count = EventLog.find(:all).count
    do_login_with_remember
    assert_not_nil cookies['user_id']
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::LOGIN
    @request.cookies['user_id'] = CGI.unescape(cookies['user_id'])
    get :new
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_redirected_to '/'
  end

  def test_should_log_login_event_with_remember_me
    log_count = EventLog.find(:all).count
    do_login_with_remember
    assert_not_nil cookies['user_id']
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::LOGIN
    session.clear
    @request.cookies['user_id'] = CGI.unescape(cookies['user_id'])
    get :new
    assert_equal log_count + 2, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::LOGIN
    assert_redirected_to '/'
  end

end
