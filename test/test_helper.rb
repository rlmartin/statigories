ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
include ActionView::Helpers::TranslationHelper
include ActionView::Helpers::JavaScriptHelper
include StringLib

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def setup
    # This sets the request object so models have access to it.
    ActiveRecord::Base::_set_request(ActionController::TestRequest.new)
  end

  # Add more helper methods to be used by all tests here...
  def assert_error_redirect(error_name)
    assert_redirected_to error_path
    assert_equal flash[:error], t(error_name)
    assert_equal flash[:notice] || '', ''
  end

  def assert_jquery(selector, method, text = nil, bolExact = false, bolEscapeJS = true, bolEscapeRE = true, bolNotMatch = false)
    reMatch = nil
    if text == nil
      if bolExact
        reMatch = /\$\(['"]#{StringLib.escape_reg_exp(selector)}['"]\)\.#{method}\(\)/
      else
        reMatch = /\$\(['"]#{StringLib.escape_reg_exp(selector)}['"]\).*\.#{method}\(\)/
      end
    else
      text = t(text) if text.is_a?(Symbol)
      text = escape_javascript(text) if bolEscapeJS
      text = StringLib.escape_reg_exp(text) if bolEscapeRE
      if bolExact
        reMatch = /\$\(['"]#{StringLib.escape_reg_exp(selector)}['"]\)\.#{method}\(['"]#{text}['"]\)/
      else
        reMatch = /\$\(['"]#{StringLib.escape_reg_exp(selector)}['"]\).*\.#{method}\(['"].*#{text}.*['"]\)/
      end
    end
    unless reMatch == nil
      if bolNotMatch
        assert_no_match reMatch, @response.body
      else
        assert_match reMatch, @response.body
      end
    end
  end

  def assert_not_jquery(selector, method, text = nil, bolExact = false, bolEscapeJS = true, bolEscapeRE = true)
    assert_jquery selector, method, text, bolExact, bolEscapeJS, bolEscapeRE, true
  end

  def assert_select_match_text(selector, text)
    css_select(selector).each do |e|
      assert e.match(:child => Regexp.new(text))
    end
  end

  def assert_jquery_error(msg_name)
    assert_jquery_messages msg_name, nil
  end

  def assert_xhr_error(msg_name)
    assert_xhr_messages msg_name, nil
  end

  def assert_jquery_messages(error_msg, notice_msg)
    if error_msg == nil
      assert_jquery '#error_msg', 'hide'
      error_msg = ''
    end
    assert_jquery '#error_msg', 'html', error_msg, true
    if notice_msg == nil
      assert_jquery '#notice_msg', 'hide'
      notice_msg = ''
    end
    assert_jquery '#notice_msg', 'html', notice_msg, true
  end

  def assert_xhr_messages(error_msg, notice_msg)
    assert_rjs_text error_msg, 'error_msg'
    assert_rjs_text notice_msg, 'notice_msg'
  end

  def assert_jquery_notice(msg_name)
    assert_jquery_messages nil, msg_name
  end

  def assert_xhr_notice(msg_name)
    assert_xhr_messages nil, msg_name
  end

  def assert_jquery_link(parent_class, url = nil, text = nil, method = nil, remote = false)
    text = t(text) if text.is_a?(Symbol)
    assert_jquery parent_class, 'html', text unless url == nil
    assert_jquery parent_class, 'html', '<a .*' + StringLib.escape_reg_exp(escape_javascript("href=\"#{url}\"")) + '.*>' + StringLib.escape_reg_exp(escape_javascript(text + '</a>')), false, false, false unless text == nil
    assert_jquery parent_class, 'html', '<a .*' + StringLib.escape_reg_exp(escape_javascript("data-method=\"#{method}\"")) + '.*>' + StringLib.escape_reg_exp(escape_javascript(text + '</a>')), false, false, false unless method == nil
    assert_jquery parent_class, 'html', "<a .*#{StringLib.escape_reg_exp(escape_javascript('data-remote="true"'))}.*>" + StringLib.escape_reg_exp(escape_javascript(text + '</a>')), false, false, false if remote
  end

  def assert_login_redirect
    assert_redirected_to login_path + '?url=' + CGI::escape(@request.url)
  end

  def assert_rjs_text(message = nil, class_name = '', tag_name = 'span')
    message = t(message) if message != nil and message.is_a?(Symbol)
    assert_select_rjs :chained_replace_html, class_name do |elements|
      assert_select tag_name, message
    end
  end

  def change_constant(name, value)
    if CONST_LIST['test'] and CONST_LIST['test'][name.to_s]
      CONST_LIST['test'][name.to_s]['value'] = value
      CONST_LIST['test'][name.to_s]['stale'] = true
    else
      CONST_LIST['default'][name.to_s]['value'] = value
      CONST_LIST['default'][name.to_s]['stale'] = true
    end
  end

  def do_login_in_session_controller(user = :ryan, redirect_url = nil, remember_me = nil)
    post :create, :email => users(user).email, :password => 'pwd', :remember_me => remember_me, :url => redirect_url
  end

  def do_login(user = :ryan, redirect_url = nil)
    old_controller = @controller
    @controller = SessionsController.new
    do_login_in_session_controller user, redirect_url
#    post :create, :email => users(user).email, :password => 'pwd', :url => redirect_url
    @controller = old_controller
  end

  def do_login_with_remember_in_session_controller(user = :ryan, redirect_url = nil)
    do_login_in_session_controller user, redirect_url, '1'
  end

  def do_login_with_remember(user = :ryan, redirect_url = nil)
    old_controller = @controller
    @controller = SessionsController.new
    do_login_with_remember_in_session_controller user, redirect_url
#    post :create, :email => users(user).email, :password => 'pwd', :remember_me => '1', :url => redirect_url
    @controller = old_controller
  end

  def h(str)
    CGI.escapeHTML(str)
  end

  def load_user_page(user = :ryan)
    old_controller = @controller
    @controller = UsersController.new
    get :show, :username => users(user).username
    @controller = old_controller
  end

  def timezone_offset(now = Time.now)
    StringLib.to_timezone(now.zone).current_period.utc_offset.to_f / 86400
  end

  #def t(*args)
  #  I18n.t(args[0], args.extract_options!)
  #end

end
