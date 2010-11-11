ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

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

  def assert_select_match_text(selector, text)
    css_select(selector).each do |e|
      assert e.match(:child => Regexp.new(text))
    end
  end

  def assert_xhr_error(msg_name)
    assert_xhr_messages msg_name, nil
  end

  def assert_xhr_messages(error_msg, notice_msg)
    assert_rjs_text error_msg, 'error_msg'
    assert_rjs_text notice_msg, 'notice_msg'
  end

  def assert_xhr_notice(msg_name)
    assert_xhr_messages nil, msg_name
  end

  def assert_login_redirect
    assert_redirected_to login_path + '?url=' + CGI::escape(@request.url)
  end

  def assert_rjs_text(message = nil, class_name = '', tag_name = 'span')
    if message != nil and message.is_a?(Symbol): message = t(message) end
    assert_select_rjs :chained_replace_html, class_name do |elements|
      assert_select tag_name, message
    end
  end

  def change_constant(name, value)
    c = Constant.find_by_name(name)
    assert_not_nil c
    c.update_attributes(:value => value)
    Constant::refresh!(name)
  end

  def do_login(user = :ryan, redirect_url = nil)
    old_controller = @controller
    @controller = SessionsController.new
    post :create, :email => users(user).email, :password => 'pwd', :url => redirect_url
    @controller = old_controller
  end

  def do_login_with_remember(user = :ryan, redirect_url = nil)
    old_controller = @controller
    @controller = SessionsController.new
    post :create, :email => users(user).email, :password => 'pwd', :remember_me => '1', :url => redirect_url
    @controller = old_controller
  end

  def load_user_page(user = :ryan)
    old_controller = @controller
    @controller = UsersController.new
    get :show, :username => users(user).username
    @controller = old_controller
  end

  def t(*args)
    I18n.t(args[0], args.extract_options!)
  end

end
