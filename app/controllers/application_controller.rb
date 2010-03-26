# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	include DateLib

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  before_filter :set_model_request
	before_filter :set_locale
	before_filter :before_filter_init_page
	before_filter :fetch_logged_in_user

	def logged_in_check
		unless @_me == nil
			if @_me[:id] > 0
				unless @_me[:verified] or DateLib.is_after((@_me[:created_at] + 1.day), Time.now)
					redirect_to verify_check_path
				end
			else
				redirect_to login_path
			end
		end
	end

	protected

  # Redirect to the error page if 'condition' is false. Use 'msg' symbol to set the message from the translation lookup.
  def error_page_on_fail(condition, msg)
    unless condition
      flash[:error] = t(msg)
      unless request.xhr?: redirect_to error_path end
      return true
    end
    false
  end

	def fetch_logged_in_user
		if session[:user_id] == nil and cookies[:user_id] != nil and cookies[:user_id] != '': session[:user_id] = AESCrypt::decrypt(cookies[:user_id]).to_i end
		if session[:user_id] != nil and session[:user_id] > 0 and (session[:logged_in] == nil or session[:logged_in] == false)
			@_me = User.find_by_id(session[:user_id])
			unless @_me == nil
				session[:username] = @_me.username
				session[:name] = @_me.first_name
				session[:logged_in] = true
        # Save the user object into the session, but with only the attributes and none of the secondary collections/relationships/etc.
        _user = {}
        @_me.attributes.each { |key, value| _user[key.to_sym] = value }
				session[:_me] = _user
        _user = nil
#				session[:_me] = @_me
        @_me.add_login_event
        @_me = nil
			end
		end
		@_me = session[:_me]
	end

  def before_filter_init_page
    @page = { :description => "", :keywords => "", :main_class => "", :title => "" }
		@can_edit = false
		@can_view = false
		@can_delete = false
    @success = false
  end

  def is_mine
    if @user == nil
      false
    else
      (@user.id == my_user_id)
    end
  end

  def load_group_from_param
    if @user == nil: redirect_to user_path(params[:username]) end
    @group = nil
    unless @user == nil
      @group = @user.groups.find_by_group_name(params[:group_name])
      unless @group == nil: @page[:title] = @group.name + ' : ' + @page[:title] end
    end
  end

	def load_permissions_for_user
		if @user != nil and @user.id == session[:user_id]
			@can_edit = true
			@can_delete = true
			@can_view = true
		end
	end

	def load_user_from_param
		@page[:title] = t(:title_error_user_not_found)
    if params[:username] == nil and params[:user][:username] != nil: params[:username] = params[:user][:username] end
		@user = User.find_by_username(params[:username])
		if @user != nil
			@page[:title] = @user.first_name + ' ' + @user.last_name
		end
	end

  def my_user_id
    if @_me == nil
      0
    else
      @_me[:id]
    end
  end

  def my_username
    if @_me == nil
      ''
    else
      @_me[:username]
    end
  end

	def set_locale
		I18n.locale = :en
		if Constant::get(:accepted_languages).include?(request.subdomains.last): I18n.locale = request.subdomains.last.to_sym end
	end

	def set_logged_in(user_id, remember_me)
		session[:user_id] = user_id
    # Force reload of user info in fetch_logged_in_user
    session[:logged_in] = nil
		if remember_me
      cookies[:user_id] = { :value => AESCrypt::encrypt(user_id.to_s), :expires => 1.month.from_now }
		else
      cookies[:user_id] = nil
    end
    fetch_logged_in_user
	end

  def set_model_request
    ActiveRecord::Base::_set_request(request)
  end

	def logout
    user = User.find_by_id(session[:user_id])
    unless user == nil
      user.add_logout_event
      user = nil
    end
    session.clear
		cookies[:user_id] = nil
	end

end
