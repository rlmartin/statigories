# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
	include DateLib

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

	before_filter :set_locale
	before_filter :before_filter_init_page
	before_filter :fetch_logged_in_user

	def logged_in_check
		unless @_me == nil
			if @_me.id > 0
				unless @_me.verified or DateLib.is_after((@_me.created_at + 1.day), Time.now)
					redirect_to verify_check_path
				end
			else
				redirect_to login_path
			end
		end
	end

	protected

	def fetch_logged_in_user
		if session[:user_id] == nil and cookies[:user_id] != nil and cookies[:user_id] != '': session[:user_id] = AESCrypt::decrypt(cookies[:user_id]).to_i end
		if session[:user_id] != nil and session[:user_id] > 0 and (session[:logged_in] == nil or session[:logged_in] == false)
			@_me = User.find_by_id(session[:user_id])
			unless @_me == nil
				session[:username] = @_me.username
				session[:name] = @_me.first_name
				session[:logged_in] = true
				session[:_me] = @_me
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
  end

	def load_permissions_for_user
		if @user != nil and @user.id == session[:user_id]
			@can_edit = true
			@can_delete = true
			@can_view = true
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
		if remember_me: cookies[:user_id] = { :value => AESCrypt::encrypt(user_id.to_s), :expires => 1.month.from_now }
		else cookies[:user_id] = nil end
    fetch_logged_in_user
	end

	def logout
		session[:user_id] = nil
		session[:username] = nil
		session[:name] = nil
		session[:logged_in] = nil
		session[:_me] = nil
		cookies[:user_id] = nil
	end

end
