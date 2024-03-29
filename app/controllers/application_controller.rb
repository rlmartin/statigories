require 'aes_crypt'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	include DateLib
  include StringLib

  # Scrub sensitive parameters from your log

  before_filter :set_model_request
	before_filter :set_locale
	before_filter :before_filter_init_page
	before_filter :fetch_logged_in_user

  def current_user
    @current_user ||=
      begin
        @current_user = User.find_by_id(session[:user_id])
      end
  end

  def current_user_stub
    if @current_user_stub == nil or (session[:user_id] != nil and session[:user_id] > 0 and @current_user_stub != nil and @current_user_stub.id == nil)
      @current_user_stub = User.new
      if @current_user == nil
        @current_user_stub.id = session[:user_id]
        @current_user_stub.username = session[:username]
        @current_user_stub.first_name = session[:first_name]
        @current_user_stub.last_name = session[:last_name]
        @current_user_stub.verified = session[:verified]
        @current_user_stub.created_at = session[:created_at]
      else
        @current_user_stub.id = @current_user.id
        @current_user_stub.username = @current_user.username
        @current_user_stub.first_name = @current_user.first_name
        @current_user_stub.last_name = @current_user.last_name
        @current_user_stub.verified = @current_user.verified
        @current_user_stub.created_at = @current_user.created_at
      end
    end
    @current_user_stub
  end

	def logged_in_check
		unless current_user_stub == nil
			if current_user_stub.id != nil and current_user_stub.id > 0
				unless current_user_stub.verified or DateLib.is_after((current_user_stub.created_at + 1.day), Time.now)
          respond_to do |format|
            format.js { render 'users/verify_check' }
            format.any { redirect_to verify_check_path }
          end
				end
			else
        if request.xhr?
          unless performed?
            respond_to do |format|
              format.js { render 'sessions/new' }
              format.any { redirect_to login_path + '?url=' + StringLib.url_encode(request.url) }
            end
          end
        else
  				redirect_to login_path + '?url=' + StringLib.url_encode(request.url)
        end
			end
		end
    true
	end

	protected

  def check_authorization(condition, msg)
    unless condition
      if oauth?
        invalid_oauth_response 401, t(msg)
      else
        flash[:error] = t(msg)
        if request.xhr?
          render 'general_page/auth_response' unless performed?
        else
          redirect_to error_path
        end
      end
      return false
    end
    true
  end

  def check_authorization_delete(msg = :msg_not_authorized)
    check_authorization @can_delete, msg
  end

  def check_authorization_edit(msg = :msg_not_authorized)
    check_authorization @can_edit, msg
  end

  def check_authorization_view(msg = :msg_not_authorized)
    check_authorization @can_view, msg
  end

  # Redirect to the error page if 'condition' is false. Use 'msg' symbol to set the message from the translation lookup.
  def error_page_on_fail(condition, msg)
    unless condition
      if oauth?
        invalid_oauth_response 401, t(msg)
      else
        flash[:error] = t(msg)
        redirect_to error_path unless request.xhr?
      end
      return true
    end
    false
  end

	def fetch_logged_in_user
		session[:user_id] = AESCrypt::decrypt(cookies[:user_id]).to_i if session[:user_id] == nil and cookies[:user_id] != nil and cookies[:user_id] != ''
		if session[:user_id] != nil and session[:user_id] > 0 and (session[:logged_in] == nil or session[:logged_in] == false)
			@current_user = User.find_by_id(session[:user_id])
			unless @current_user == nil
				session[:username] = @current_user.username
				session[:name] = @current_user.first_name
				session[:first_name] = @current_user.first_name
				session[:last_name] = @current_user.last_name
				session[:verified] = @current_user.verified
				session[:created_at] = @current_user.created_at
				session[:logged_in] = true
        @current_user.add_login_event
			end
		end
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
    redirect_to user_path(params[:username]) if @user == nil
    @group = nil
    unless @user == nil
      @group = @user.groups.find_by_group_name(params[:group_name])
      @page[:title] = @group.name + ' : ' + @page[:title] unless @group == nil
    end
  end

	def load_permissions_for_user
		if @user != nil and @user.id == session[:user_id]
			@can_edit = true
			@can_delete = true
			@can_view = true
		end
	end

	def load_user_from_param(bolAllowCurrentUser = false)
		@page[:title] = t(:title_error_user_not_found)
    params[:username] = params[:user][:username] if params[:username] == nil and params[:user] and params[:user][:username] != nil
    if params[:username]
		  @user = User.find_by_username(params[:username])
    else
      @user = current_user
    end
	  if @user
		  @page[:title] = @user.first_name + ' ' + @user.last_name
	  end
	end

	def load_user_from_param_or_current_user
    load_user_from_param(true)
  end

  def my_user_id
    if current_user_stub == nil
      0
    else
      current_user_stub.id
    end
  end

  def my_username
    if current_user_stub == nil
      ''
    else
      current_user_stub.username
    end
  end

	def set_locale
		I18n.locale = :en
		I18n.locale = request.subdomains.last.to_sym if Const::get(:accepted_languages).include?(request.subdomains.last)
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
    Thread.current['request'] = request
    ActiveRecord::Base::_set_request(request)
  end

	def logout
    user = User.find_by_id(session[:user_id])
    unless current_user == nil
      current_user.add_logout_event
      @current_user = nil
    end
    session.clear
		cookies[:user_id] = nil
	end

  def login_required
    logged_in_check
  end

  def authorized?
    login_required
  end

end
