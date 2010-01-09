require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def test_login_display
    # This probably shouldn't be here, but it is easiest to put it here now.
    # Check when not logged in.
    get :show, :username => users(:user1).username
    assert_select "div.login_panel a", :count => 1
    assert_select "div.login_panel a[href=#{login_path}]", I18n.t(:link_login)
    # Check header info when logged in.
    do_login
    get :show, :username => users(:user1).username
    assert_select "div.login_panel a", :count => 2
    assert_select "div.login_panel a[href=#{user_path(users(:ryan))}]", :count => 1
    assert_select "div.login_panel a[href=#{user_path(users(:ryan))}]", users(:ryan).first_name
    assert_select "div.login_panel a[href=#{logout_path}]", I18n.t(:link_logout)
  end

  def test_should_show_signup
    get :new
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    # Has correct title text
    assert_select "h1", I18n.t(:title_signup)
    # Has correct submit URL
    assert_select "form[action=#{new_user_path}]", :count => 1
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_create)}]", :count => 1
    # Does not show "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 0
  end

  def test_should_add_user
    post :create, :user => {
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'johndoe@gmail.com',
      :email_confirmation => 'johndoe@gmail.com',
      :username => 'john',
      :password => 'xxxx',
      :password_confirmation => 'xxxx'
    }
    assert ! assigns(:user).new_record?
    assert_redirected_to login_path
    assert_nil flash[:error]
    # Make sure the new user is automatically logged in
    assert_not_nil session[:user_id]
    assert session[:logged_in]
  end

  def test_should_not_add_user
    post :create, :user => {
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'johndoe@gmail.com',
      :email_confirmation => 'johndoe1@gmail.com',
      :username => 'john',
      :password => 'xxxx',
      :password_confirmation => 'xxxx'
    }
    assert assigns(:user).new_record?
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    assert assigns(:user).errors.on(:email)
    # Has correct title text
    assert_select "h1", I18n.t(:title_signup)
    # Has correct submit URL
    assert_select "form[action=#{new_user_path}]", :count => 1
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_create)}]", :count => 1
    # Does not show "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 0
    # Old values still displayed
    assert_equal assigns(:user).email, 'johndoe@gmail.com'
  end

  def test_should_delete_user
    assert_not_nil User.find_by_id(users(:ryan).id)
    do_login
    assert_not_nil session[:logged_in]
    log_count = EventLog.find(:all).count
    get :destroy, :username => users(:ryan).username
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::USER_DELETED
    assert_equal EventLog.find(:last).event_data, users(:ryan).id.to_s
    assert_nil User.find_by_id(users(:ryan).id)
    assert_select "h1", I18n.t(:title_user_delete)
    # Check that user is logged out after delete.
    assert_nil session[:logged_in]
    assert_select "div.login_panel a", :count => 1
    assert_select "div.login_panel a[href=#{login_path}]", I18n.t(:link_login)
  end

  def test_should_not_delete_user_when_not_logged_in
    assert_not_nil User.find_by_id(users(:ryan).id)
    log_count = EventLog.find(:all).count
    get :destroy, :username => users(:ryan).username
    assert_equal log_count, EventLog.find(:all).count
    assert_redirected_to user_path(users(:ryan).username)
    assert_not_nil User.find_by_id(users(:ryan).id)
  end

  def test_should_not_delete_user_when_not_own_user
    assert_not_nil User.find_by_id(users(:user1).id)
    do_login
    log_count = EventLog.find(:all).count
    get :destroy, :username => users(:user1).username
    assert_equal log_count, EventLog.find(:all).count
    assert_redirected_to user_path(users(:user1).username)
    assert_not_nil User.find_by_id(users(:user1).id)
  end

  def test_should_show_edit
    do_login
    get :edit, :username => users(:ryan).username
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    # Has correct title text
    assert_select "h1", I18n.t(:title_edit_user)
    # Has correct submit URL, for both the edit form and the delete button
    assert_select "form[action=#{user_path}]", :count => 2
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_save)}]", :count => 1
    # Shows "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 1
  end

  def test_should_not_show_edit_for_different_user
    do_login
    get :edit, :username => users(:user1).username
    assert_redirected_to user_path(users(:user1).username)
    assert_template :show
    assert_not_nil assigns(:user)
  end

  def test_should_not_show_edit_button_for_not_logged_in
    get :show, :username => users(:user1).username
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    # Has correct title text
    assert_select "h1", users(:user1).first_name + ' ' + users(:user1).last_name
    # Has no edit button
    assert_select "form[method=get][action=#{edit_user_path(users(:user1).username)}]", :count => 0
  end

  def test_should_not_show_edit_button_for_different_user
    do_login
    get :show, :username => users(:user1).username
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    # Has correct title text
    assert_select "h1", users(:user1).first_name + ' ' + users(:user1).last_name
    # Has no edit button
    assert_select "form[method=get][action=#{edit_user_path(users(:user1).username)}]", :count => 0
    # Has friends link
    assert_select "a[href=#{user_friends_path(users(:user1).username)}]", I18n.t(:link_user_friends)
  end

  def test_should_show_edit_button_for_own_profile
    do_login
    get :show, :username => users(:ryan).username
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    # Has correct title text
    assert_select "h1", users(:ryan).first_name + ' ' + users(:ryan).last_name
    # Has no edit button
    assert_select "form[method=get][action=#{edit_user_path(users(:ryan).username)}]", :count => 1
    # Has friends link
    assert_select "a[href=#{user_friends_path(users(:ryan).username)}]", I18n.t(:link_user_friends)
  end

  def test_should_show_forgot_password_form
    get :forgot_password
    assert_response :success
    assert_template :forgot_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{forgot_password_path}]", :count => 1
    assert_select "form[action=#{forgot_password_path}] input[type=text][name=email]", :count => 1
    assert_select "form[action=#{forgot_password_path}] input[type=submit][value=#{I18n.t(:btn_send)}]", :count => 1
  end

  def test_should_send_forgot_password_email_also_check_msg_sent_event
    # Store initial values.
    num_deliveries = ActionMailer::Base.deliveries.size
    log_count = EventLog.find(:all).count
    @request.env["HTTP_USER_AGENT"] = 'hihi'
    @request.env["REMOTE_ADDR"] = '2.2.2.2'
    # Send the email
    u = User.find_by_id(users(:ryan).id)
    assert_equal u.password_recovery_code, ''
    assert_nil u.password_recovery_code_set
    post :process_forgot_password, :email => users(:ryan).email
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::EMAIL_MSG_SENT
    assert_equal EventLog.find(:last).user_id, u.id
    # Check the request properties.
    assert_equal EventLog.find(:last).user_agent.user_agent, 'hihi'
    assert_equal EventLog.find(:last).ip_address, '2.2.2.2'
    # Check user
    u = User.find_by_id(users(:ryan).id)
    assert_not_equal u.password_recovery_code, ''
    assert_not_nil u.password_recovery_code_set
    # Check results page
    assert_response :success
    assert_template :forgot_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{forgot_password_path}]", :count => 0
    assert_select "div.notice_msg", I18n.t(:msg_reset_password_sent)
    assert_select "div.error_msg", :count => 1
    assert_select "div.error_msg", ''
  end

  def test_should_not_send_forgot_password_email
    num_deliveries = ActionMailer::Base.deliveries.size
    post :process_forgot_password, :email => 'xx' + users(:ryan).email
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Check results page
    assert_response :success
    assert_template :forgot_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{forgot_password_path}]", :count => 1
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    assert_select "div.error_msg", I18n.t(:msg_email_not_found)
  end

  def test_should_show_resend_verify_form
    get :resend_verify
    assert_response :success
    assert_template :resend_verify
    assert_select "h1", I18n.t(:title_email_verification)
    assert_select "form[action=#{resend_verify_path}]", :count => 1
    assert_select "form[action=#{resend_verify_path}] input[type=text][name=email]", :count => 1
    assert_select "form[action=#{resend_verify_path}] input[type=submit][value=#{I18n.t(:btn_send)}]", :count => 1
  end

  def test_should_resend_verify_email
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user3).id)
    assert !u.verified
    post :process_resend_verify, :email => users(:user3).email
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    # Check user
    u = User.find_by_id(users(:user3).id)
    assert_not_equal u.verification_code, ''
    # Check results page
    assert_response :success
    assert_template :resend_verify
    assert_select "h1", I18n.t(:title_email_verification)
    assert_select "form[action=#{resend_verify_path}]", :count => 0
    assert_select "div.notice_msg", I18n.t(:msg_verification_sent)
    assert_select "div.error_msg", :count => 1
    assert_select "div.error_msg", ''
  end

  def test_should_resend_verify_email_even_if_code_blank_also_check_msg_sent_event
    num_deliveries = ActionMailer::Base.deliveries.size
    log_count = EventLog.find(:all).count
    @request.env["HTTP_USER_AGENT"] = 'hihi'
    @request.env["REMOTE_ADDR"] = '2.2.2.2'
    u = User.find_by_id(users(:user2).id)
    assert_equal u.verification_code, ''
    assert !u.verified
    post :process_resend_verify, :email => users(:user2).email
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::EMAIL_MSG_SENT
    assert_equal EventLog.find(:last).user_id, u.id
    # Check the request properties.
    assert_equal EventLog.find(:last).user_agent.user_agent, 'hihi'
    assert_equal EventLog.find(:last).ip_address, '2.2.2.2'
    # Check user
    u = User.find_by_id(users(:user2).id)
    assert_not_equal u.verification_code, ''
    # Check results page
    assert_response :success
    assert_template :resend_verify
    assert_select "h1", I18n.t(:title_email_verification)
    assert_select "form[action=#{resend_verify_path}]", :count => 0
    assert_select "div.notice_msg", I18n.t(:msg_verification_sent)
    assert_select "div.error_msg", :count => 1
    assert_select "div.error_msg", ''
  end

  def test_should_not_resend_verify_email_email_not_found
    num_deliveries = ActionMailer::Base.deliveries.size
    post :process_resend_verify, :email => 'xx' + users(:ryan).email
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Check results page
    assert_response :success
    assert_template :resend_verify
    assert_select "h1", I18n.t(:title_email_verification)
    assert_select "form[action=#{resend_verify_path}]", :count => 1
    assert_select "form[action=#{resend_verify_path}] input[type=text][name=email]", :count => 1
    assert_select "form[action=#{resend_verify_path}] input[type=submit][value=#{I18n.t(:btn_send)}]", :count => 1
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    assert_select "div.error_msg", I18n.t(:msg_email_not_found)
  end

  def test_should_not_resend_verify_email_already_verified
    num_deliveries = ActionMailer::Base.deliveries.size
    post :process_resend_verify, :email => users(:ryan).email
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Check results page
    assert_response :success
    assert_template :resend_verify
    assert_select "h1", I18n.t(:title_email_verification)
    assert_select "form[action=#{resend_verify_path}]", :count => 1
    assert_select "form[action=#{resend_verify_path}] input[type=text][name=email]", :count => 1
    assert_select "form[action=#{resend_verify_path}] input[type=submit][value=#{I18n.t(:btn_send)}]", :count => 1
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    # The HTML is being cleaned up here, so this just makes sure the error message is not blank.
    assert_select "div.error_msg", /.+/
  end

  def test_should_show_reset_password_form
    u = User.find_by_id(users(:ryan).id)
    assert u.send_password_email
    code = u.password_recovery_code
    get :reset_password, { :username => users(:ryan).username, :code => code}
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 1
    assert_select "form[action=#{reset_password_path(users(:ryan))}] input[type=password][name='user[password]']", :count => 1
    assert_select "form[action=#{reset_password_path(users(:ryan))}] input[type=password][name='user[password_confirmation]']", :count => 1
    assert_select "form[action=#{reset_password_path(users(:ryan))}] input[type=submit][value=#{I18n.t(:btn_save)}]", :count => 1
    assert_select "form[action=#{reset_password_path(users(:ryan))}] input[type=hidden][name=password_recovery_code][value=#{code}]", :count => 1
  end

  def test_should_not_show_reset_password_form_missing_user
    get :reset_password, :username => 'xx' + users(:ryan).username
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 0
    assert_select "div.error_msg", I18n.t(:msg_user_not_found)
  end

  def test_should_not_show_reset_password_form_invalid_code
    u = User.find_by_id(users(:ryan).id)
    assert u.send_password_email
    code = u.password_recovery_code
    get :reset_password, { :username => users(:ryan).username, :code => code + 'xx'}
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 0
    # The HTML is being cleaned up here, so this just makes sure the error message is not blank.
    assert_select "div.error_msg", /.+/
  end

  def test_should_do_reset_password
    u = User.find_by_id(users(:ryan).id)
    assert u.send_password_email
    code = u.password_recovery_code
    post :process_reset_password, { :username => users(:ryan).username, :password_recovery_code => code, :user => { :password => 'pwd1', :password_confirmation => 'pwd1' } }
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 0
    assert_select "div.error_msg", :count => 1
    assert_select "div.error_msg", ''
    assert_select "div.notice_msg", I18n.t(:msg_password_set)
    # Check user
    u = User.find_by_id(users(:ryan).id)
    assert_equal u.password, Digest::MD5.hexdigest('pwd1')
    assert_equal u.password_recovery_code, ''
    assert_nil u.password_recovery_code_set
    # Should also automatically log in
    assert session[:logged_in]
    assert_not_nil session[:_me]
    assert_not_nil assigns(:_me)
    assert_not_nil session[:user_id]
  end

  def test_should_not_reset_password_missing_username
    post :process_reset_password, { :username => 'xx' + users(:ryan).username, :password_recovery_code => 'xx', :user => { :password => 'pwd1', :password_confirmation => 'pwd1' } }
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 0
    assert_select "div.error_msg", I18n.t(:msg_user_not_found)
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
  end

  def test_should_not_reset_password_invalid_code
    u = User.find_by_id(users(:ryan).id)
    assert u.send_password_email
    code = u.password_recovery_code
    post :process_reset_password, { :username => users(:ryan).username, :password_recovery_code => code + 'xx', :user => { :password => 'pwd1', :password_confirmation => 'pwd1' } }
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 1
    assert_select "div.error_msg", /.+/
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    # Check user
    u = User.find_by_id(users(:ryan).id)
    assert_equal u.password, users(:ryan).password
    assert_equal u.password_recovery_code, code
    assert_not_nil u.password_recovery_code_set
    # Should not automatically log in
    assert_nil session[:logged_in]
    assert_nil session[:_me]
    assert_nil assigns(:_me)
    assert_nil session[:user_id]
  end

  def test_should_not_reset_password_invalid_confirmation
    u = User.find_by_id(users(:ryan).id)
    assert u.send_password_email
    code = u.password_recovery_code
    post :process_reset_password, { :username => users(:ryan).username, :password_recovery_code => code, :user => { :password => 'pwd1', :password_confirmation => 'pwd2' } }
    assert_response :success
    assert_template :reset_password
    assert_select "h1", I18n.t(:title_forgot_password)
    assert_select "form[action=#{reset_password_path(users(:ryan))}]", :count => 1
    assert_select "div.error_msg", I18n.t(:msg_general_error)
    assert_select "form[action=#{reset_password_path(users(:ryan))}] div.error_msg", /.+/
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    # Check user
    u = User.find_by_id(users(:ryan).id)
    assert_equal u.password, users(:ryan).password
    assert_equal u.password_recovery_code, code
    assert_not_nil u.password_recovery_code_set
    # Should not automatically log in
    assert_nil session[:logged_in]
    assert_nil session[:_me]
    assert_nil assigns(:_me)
    assert_nil session[:user_id]
  end

  def test_should_verify_username_availability
    xml_http_request :get, :show, :user => { :username => users(:ryan).username + 'xx' }
    assert_nil assigns(:user)
  end

  def test_should_verify_username_not_availabile
    xml_http_request :get, :show, :username => users(:ryan).username
    assert_not_nil assigns(:user)
  end

  def test_should_update_user
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:ryan).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :ryan
    # Use the authoried email to test the automatic email verification sending.
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:ryan).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'test5a@mylo.gs',
      :email_confirmation => 'test5a@mylo.gs',
      :username => 'john',
      :password => 'xxxx',
      :password_confirmation => 'xxxx'
    }
    assert ! assigns(:user).new_record?
    assert_redirected_to user_path(:username => 'john')
    assert_nil flash[:error]
    assert_not_nil flash[:notice]
    assert_equal flash[:notice], I18n.t(:msg_profile_saved)
    # One logged event for each: user edited, msg sent
    assert_equal log_count + 2, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::USER_EDITED
    # Make sure the verification email was sent.
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    # Check the user
    u = User.find_by_id(users(:ryan).id)
    assert_not_equal u.first_name, first_name
    assert_equal u.first_name, 'John'
    assert_not_equal u.last_name, last_name
    assert_equal u.last_name, 'Doe'
    assert_not_equal u.email, email
    assert_equal u.email, 'test5a@mylo.gs'
    assert_not_equal u.username, username
    assert_equal u.username, 'john'
    assert_not_equal u.password, password
    assert_equal u.password, Digest::MD5.hexdigest('xxxx')
  end

  def test_should_update_user_but_not_email_or_password
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user3).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :user3
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user3).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => '',
      :email_confirmation => '',
      :username => 'john',
      :password => '',
      :password_confirmation => ''
    }
    assert ! assigns(:user).new_record?
    assert_redirected_to user_path(:username => 'john')
    assert_nil flash[:error]
    assert_not_nil flash[:notice]
    assert_equal flash[:notice], I18n.t(:msg_profile_saved)
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::USER_EDITED
    # Make sure the verification email was not sent.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Check the user
    u = User.find_by_id(users(:user3).id)
    assert_not_equal u.first_name, first_name
    assert_equal u.first_name, 'John'
    assert_not_equal u.last_name, last_name
    assert_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, ''
    assert_not_equal u.username, username
    assert_equal u.username, 'john'
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('')
  end

  def test_should_update_user_but_not_email_or_password_and_resend_verify_if_not_verified_but_code_blank
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :user2
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user2).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => '',
      :email_confirmation => '',
      :username => 'john',
      :password => '',
      :password_confirmation => ''
    }
    assert ! assigns(:user).new_record?
    assert_redirected_to user_path(:username => 'john')
    assert_nil flash[:error]
    assert_not_nil flash[:notice]
    assert_equal flash[:notice], I18n.t(:msg_profile_saved)
    # One logged event for each: user edited, msg sent
    assert_equal log_count + 2, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::USER_EDITED
    # Make sure the verification email was sent.
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    # Check the user
    u = User.find_by_id(users(:user2).id)
    assert_not_equal u.first_name, first_name
    assert_equal u.first_name, 'John'
    assert_not_equal u.last_name, last_name
    assert_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, ''
    assert_not_equal u.username, username
    assert_equal u.username, 'john'
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('')
  end

  def test_should_not_update_user_invalid_email_confirmation
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :user2
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user2).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'test4@mylo.gs',
      :email_confirmation => 'test4a@mylo.gs',
      :username => 'john',
      :password => '',
      :password_confirmation => ''
    }
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    assert assigns(:user).errors.on(:email)
    assert_equal log_count, EventLog.find(:all).count
    # Make sure the verification email was not sent.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Has correct title text
    assert_select "h1", I18n.t(:title_edit_user)
    # Has correct submit URL
    assert_select "form[action=#{user_path(users(:user2).username)}]", :count => 1
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_save)}]", :count => 1
    # Shows "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 1
    # Old values still displayed
    assert_equal assigns(:user).email, 'test4@mylo.gs'
    # Check the user
    u = User.find_by_id(users(:user2).id)
    assert_equal u.first_name, first_name
    assert_not_equal u.first_name, 'John'
    assert_equal u.last_name, last_name
    assert_not_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, 'test4@mylo.gs'
    assert_equal u.username, username
    assert_not_equal u.username, 'john'
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('')
  end

  def test_should_not_update_user_invalid_email
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :user2
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user2).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => 'test4@mylo.gs1',
      :email_confirmation => 'test4@mylo.gs1',
      :username => 'john',
      :password => '',
      :password_confirmation => ''
    }
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    assert assigns(:user).errors.on(:email)
    assert_equal log_count, EventLog.find(:all).count
    # Make sure the verification email was not sent.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Has correct title text
    assert_select "h1", I18n.t(:title_edit_user)
    # Has correct submit URL
    assert_select "form[action=#{user_path(users(:user2).username)}]", :count => 1
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_save)}]", :count => 1
    # Shows "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 1
    # Old values still displayed
    assert_equal assigns(:user).email, 'test4@mylo.gs1'
    # Check the user
    u = User.find_by_id(users(:user2).id)
    assert_equal u.first_name, first_name
    assert_not_equal u.first_name, 'John'
    assert_equal u.last_name, last_name
    assert_not_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, 'test4@mylo.gs1'
    assert_equal u.username, username
    assert_not_equal u.username, 'john'
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('')
  end

  def test_should_not_update_user_invalid_password_confirmation
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :user2
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user2).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => '',
      :email_confirmation => '',
      :username => 'john',
      :password => 'pwd1',
      :password_confirmation => 'pwd2'
    }
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    assert assigns(:user).errors.on(:password)
    assert_equal log_count, EventLog.find(:all).count
    # Make sure the verification email was not sent.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Has correct title text
    assert_select "h1", I18n.t(:title_edit_user)
    # Has correct submit URL
    assert_select "form[action=#{user_path(users(:user2).username)}]", :count => 1
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_save)}]", :count => 1
    # Shows "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 1
    # Check the user
    u = User.find_by_id(users(:user2).id)
    assert_equal u.first_name, first_name
    assert_not_equal u.first_name, 'John'
    assert_equal u.last_name, last_name
    assert_not_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, ''
    assert_equal u.username, username
    assert_not_equal u.username, 'john'
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('pwd1')
  end

  def test_should_not_update_user_existing_username
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    do_login :user2
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user2).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => '',
      :email_confirmation => '',
      :username => users(:ryan).username,
      :password => '',
      :password_confirmation => ''
    }
    assert_response :success
    assert_template :edit
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:submit_to)
    assert assigns(:user).errors.on(:username)
    assert_equal log_count, EventLog.find(:all).count
    # Make sure the verification email was not sent.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Has correct title text
    assert_select "h1", I18n.t(:title_edit_user)
    # Has correct submit URL
    assert_select "form[action=#{user_path(users(:user2).username)}]", :count => 1
    # Has correct button text
    assert_select "form input[type=submit][value=#{I18n.t(:btn_save)}]", :count => 1
    # Shows "Delete account" button
    assert_select "form input[type=hidden][name=_method][value=delete]", :count => 1
    # Old values still displayed
    assert_equal assigns(:user).username, users(:ryan).username
    # Check the user
    u = User.find_by_id(users(:user2).id)
    assert_equal u.first_name, first_name
    assert_not_equal u.first_name, 'John'
    assert_equal u.last_name, last_name
    assert_not_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, ''
    assert_equal u.username, username
    assert_not_equal u.username, users(:ryan).username
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('')
  end

  def test_should_not_update_user_not_logged_in
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    first_name = u.first_name
    last_name = u.last_name
    email = u.email
    username = u.username
    password = u.password
    log_count = EventLog.find(:all).count
    post :update, :user => {
      :id => users(:user2).id,
      :first_name => 'John',
      :last_name => 'Doe',
      :email => '',
      :email_confirmation => '',
      :username => users(:ryan).username,
      :password => '',
      :password_confirmation => ''
    }
    assert_redirected_to user_path(u.username)
    assert_equal log_count, EventLog.find(:all).count
    # Make sure the verification email was not sent.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    # Check the user
    u = User.find_by_id(users(:user2).id)
    assert_equal u.first_name, first_name
    assert_not_equal u.first_name, 'John'
    assert_equal u.last_name, last_name
    assert_not_equal u.last_name, 'Doe'
    assert_equal u.email, email
    assert_not_equal u.email, ''
    assert_equal u.username, username
    assert_not_equal u.username, users(:ryan).username
    assert_equal u.password, password
    assert_not_equal u.password, Digest::MD5.hexdigest('')
  end

  def test_should_show_and_do_verify
    get :verify, { :username => users(:user3).username, :code => users(:user3).verification_code }
    assert_response :success
    assert_select "div.notice_msg", I18n.t(:msg_successful_verification_code)
    assert_select "div.error_msg", :count => 1
    assert_select "div.error_msg", ''
    u = User.find_by_id(users(:user3).id)
    assert u.verified
    assert_equal u.verification_code, ''
    assert session[:logged_in]
    assert_not_nil session[:_me]
    assert_not_nil session[:user_id]
    # Has correct title text
    assert_select "h1", I18n.t(:title_email_verification)
  end

  def test_should_show_verify_already_verified
    u = User.find_by_id(users(:ryan).id)
    assert u.verified
    get :verify, { :username => users(:ryan).username }
    assert_response :success
    assert_select "div.notice_msg", I18n.t(:msg_successful_verification_code)
    assert_select "div.error_msg", :count => 1
    assert_select "div.error_msg", ''
    # Has correct title text
    assert_select "h1", I18n.t(:title_email_verification)
  end

  def test_should_not_verify_invalid_code
    get :verify, { :username => users(:user3).username, :code => users(:user3).verification_code + 'xx' }
    assert_response :success
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    assert_select "div.error_msg", I18n.t(:msg_invalid_verification_code)
    u = User.find_by_id(users(:user3).id)
    assert !u.verified
    # Has correct title text
    assert_select "h1", I18n.t(:title_email_verification)
  end

  def test_should_not_verify_user_not_found
    assert_nil User.find_by_username(users(:user3).username + 'xx')
    get :verify, { :username => users(:user3).username + 'xx', :code => users(:user3).verification_code }
    assert_response :success
    assert_select "div.notice_msg", :count => 1
    assert_select "div.notice_msg", ''
    assert_select "div.error_msg", I18n.t(:msg_user_not_found)
    # Has correct title text
    assert_select "h1", I18n.t(:title_email_verification)
  end

  def test_verify_check_not_displayed
    do_login(:user3)
    assert_equal session[:user_id], users(:user3).id
    get :edit, :username => users(:user3).username
    assert_response :success
  end

  def test_verify_check_displayed
    u = User.find_by_id(users(:user3).id)
    assert_not_nil u
    assert !u.verified
    u.update_attributes(:created_at => u.created_at - 2.days)
    do_login(:user3)
    assert_equal session[:user_id], users(:user3).id
    get :edit, :username => users(:user3).username
    assert_redirected_to verify_check_path
    get :verify_check
    assert_select "h1", I18n.t(:title_verification_needed)
  end

  def test_verify_check_not_displayed_not_logged_in
    get :verify_check
    assert_redirected_to new_user_path
  end

  def test_check_username_availability_ajax_available
    assert_nil User.find_by_username(users(:ryan).username + 'xx')
    xhr :get, :show, :username => users(:ryan).username + 'xx'
    assert_select_rjs :chained_replace_html, 'availability_results' do |elements|
      assert_select "span", I18n.t(:msg_username_available)
    end
  end

  def test_check_username_availability_ajax_not_available
    assert_not_nil User.find_by_id(users(:ryan).id)
    xhr :get, :show, :username => users(:ryan).username
    assert_select_rjs :chained_replace_html, 'availability_results' do |elements|
      assert_select "span", I18n.t(:msg_username_taken)
    end
  end

  def test_user_default_search
    get :search
    assert_response :success
    assert_template :search
    num_users = User.find(:all).count
    assert_select 'li .user_row', :count => (num_users > Constant::get(:search_default_limit) ? Constant::get(:search_default_limit) : num_users)
  end

  def test_user_default_search_with_limit
    get :search, { :limit => 2 }
    assert_response :success
    assert_template :search
    assert_select 'li .user_row', :count => 2
  end

  def test_user_search_with_text
    get :search, { :text => 'ryan' }
    assert_response :success
    assert_template :search
    assert_select 'li .user_row', :count => 1
  end

  def test_user_search_with_text_none_found
    get :search, { :text => 'xxxxxxxx' }
    assert_response :success
    assert_template :search
    assert_select 'li .user_row', :count => 0
    assert_select "div.error_msg", :count => 2
  end

  def test_user_search_form
    get :show_search
    assert_response :success
    assert_template :show_search
    assert_select 'form input[type=text][name=text]', :count => 1
    assert_select "form input[type=submit][value=#{I18n.t(:btn_search)}]", :count => 1
  end

  def test_default_user_search_post_with_text
    post :search
    assert_response :success
    assert_template :search
    num_users = User.find(:all).count
    assert_select 'li .user_row', :count => (num_users > Constant::get(:search_default_limit) ? Constant::get(:search_default_limit) : num_users)
  end

  def test_user_search_post_with_text
    post :search, { :text => 'ryan' }
    assert_response :success
    assert_template :search
    assert_select 'li .user_row', :count => 1
  end

  def test_user_search_post_with_text_and_limit
    post :search, { :text => 'john', :limit => 3 }
    assert_response :success
    assert_template :search
    assert_select 'li .user_row', :count => 3
  end

  def test_user_row
    do_login
    post :search, { :text => 'john' }
    assert_response :success
    assert_template :search
    assert_select "li .user_row a[href=#{user_path(users(:user1).username)}]", users(:user1).first_name + ' ' + users(:user1).last_name
    assert_select "li .friend_action a[onclick*=#{user_remove_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", I18n.t(:link_delete_friend)
  end

  def test_friendship_links_for_friend
    do_login
    get :show, { :username => users(:user1).username }
    assert_response :success
    assert_template :show
    assert_select ".friend_action a[onclick*=#{user_remove_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", I18n.t(:link_delete_friend)
    #assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", :count => 0
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:ryan).id)
    u.friends << u2
    get :show, { :username => users(:user1).username }
    assert_response :success
    assert_template :show
    assert_select ".friend_action a[onclick*=#{user_remove_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", I18n.t(:link_delete_friend)
    #assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => users(:user1).username)}]", :count => 0
  end

  def test_friendship_links_for_requested_friend
    do_login :user1
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_template :show
    assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}]", I18n.t(:link_add_friend)
    assert_select ".friend_action a[onclick*=#{user_remove_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}][onclick*=delete]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}]", I18n.t(:link_ignore_friend_request)
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}]", I18n.t(:link_block_friend_request)
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:ryan).id)
    u.friends << u2
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_template :show
    assert_select ".friend_action a[onclick*=#{user_remove_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}]", I18n.t(:link_delete_friend)
    #assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}][onclick*=create]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:user1).username, :friend => users(:ryan).username)}]", :count => 0
  end

  def test_friendship_links_for_non_friend
    do_login
    get :show, { :username => users(:user3).username }
    assert_response :success
    assert_template :show
    assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", I18n.t(:link_add_friend)
    #assert_select ".friend_action a[onclick*=#{user_remove_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", :count => 0
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user3).id)
    u.friends << u2
    get :show, { :username => users(:user3).username }
    assert_response :success
    assert_template :show
    assert_select ".friend_action a[onclick*=#{user_remove_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", I18n.t(:link_delete_friend)
    #assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => users(:user3).username)}]", :count => 0
  end

end
