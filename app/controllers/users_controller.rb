class UsersController < ApplicationController
	before_filter :logged_in_check, :except => [:forgot_password, :process_forgot_password, :reset_password, :process_reset_password, :resend_verify, :process_resend_verify, :show, :verify, :verify_check]
	before_filter :set_page_vars
	before_filter [:load_user_from_param, :load_permissions_for_user], :only => [:show, :edit, :update, :destroy, :reset_password, :process_reset_password, :verify]

  def create
		@user = User.new(params[:user])
		if @user.save
			set_logged_in(@user.id, false)
			redirect_to login_path
		else
			render :edit
		end
  end

  def destroy
		# Only allow deleting if the user has permission.
		if @can_delete
			@page[:title] = Constant::get(:title_user_delete)
			User.delete(@user.id)
			logout
		else
			redirect_to user_path(@user)
		end
  end

  def edit
		# Only allow editing if the user has permission.
		unless @can_edit: redirect_to user_path(@user) end
		@submit_to = user_path
  end

	def forgot_password
		@page[:title] = t(:title_forgot_password)
	end

	def process_forgot_password
    @user = User.find_by_email(params[:email])
    if @user == nil
      flash.now[:error] = t(:msg_email_not_found)
    else
      if @user.send_password_email
        flash.now[:notice] = t(:msg_reset_password_sent)
      else
        flash.now[:error] = t(:msg_email_error)
      end
      @user = nil
    end
		@page[:title] = t(:title_forgot_password)
    render :forgot_password
	end

  def new
		@user = User.new
		@submit_to = new_user_path
		@page[:title] = t(:title_signup)
		render :edit
  end

	def resend_verify
		@page[:title] = t(:title_email_verification)
	end

	def process_resend_verify
    @user = User.find_by_email(params[:email])
    if @user == nil
      flash.now[:error] = t(:msg_email_not_found)
    elsif @user.verified
        flash.now[:error] = t(:msg_already_verified)
    else
      if @user.verification_code == ''
        @user.set_verification_code
        @user.save
      end
      if @user.send_verification_email
        flash.now[:notice] = t(:msg_verification_sent)
      else
        flash.now[:error] = t(:msg_email_error)
      end
      @user = nil
    end
		@page[:title] = t(:title_email_verification)
    render :resend_verify
	end

	def reset_password
    unless @user == nil or params[:code] == @user.password_recovery_code: flash.now[:error] = t(:msg_invalid_password_recovery_code) end
		@page[:title] = t(:title_forgot_password)
	end

	def process_reset_password
    if @user == nil
      flash.now[:error] = t(:msg_user_not_found)
    elsif @user.password_recovery_code != params[:password_recovery_code]
      flash.now[:error] = t(:msg_invalid_password_recovery_code)
    else
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      @user.password_recovery_code = ''
      @user.password_recovery_code = nil
      if @user.save
        flash.now[:notice] = t(:msg_password_set)
        set_logged_in(@user.id, false)
      else
        flash.now[:error] = t(:msg_general_error)
      end
    end
		@page[:title] = t(:title_forgot_password)
    render :reset_password
	end

  def show
  end

  def update
		@user = User.find_by_id(params[:user][:id])
		unless @user == nil
			if params[:user][:password] == ''
				params[:user].delete(:password)
				params[:user].delete(:password_confirmation)
			end
			if params[:user][:email] == '' or params[:user][:email].downcase == @user.email
				params[:user].delete(:email)
				params[:user].delete(:email_confirmation)
			end
			@user.update_attributes(params[:user])
			if @user.save
				redirect_to login_path
			else
				render :edit
			end
		end
  end

  def verify
    @verified = false
		@user = User.find_by_username(params[:username])
    unless @user == nil
		  if @user.verified
        @verified = true
		  elsif @user.verification_code == params[:code]
			  @user.verified = true
			  @user.verification_code = ''
			  @user.save
			  set_logged_in(@user.id, false)
        @verified = true
		  end
    end
  end

	def verify_check
		if @_me == nil or @_me.id <= 0: redirect_to new_user_path end
		@page[:title] = t(:title_email_verification)
	end

	protected
	def load_user_from_param
		@page[:title] = Constant::get(:title_error_user_not_found)
    if params[:username] == nil and params[:user][:username] != nil: params[:username] = params[:user][:username] end
		@user = User.find_by_username(params[:username])
		if @user != nil
			@page[:title] = @user.first_name + ' ' + @user.last_name
		end
	end

	def set_page_vars
		@page[:subtitle] = Constant::get(:subtitle_users)
	end

end
