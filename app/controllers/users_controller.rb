class UsersController < ApplicationController
	before_filter :login_or_oauth_required, :except => [:create, :forgot_password, :new, :process_forgot_password, :process_resend_verify, :process_reset_password, :resend_verify, :reset_password, :search, :show, :show_search, :verify, :verify_check]
	before_filter :set_page_vars
	before_filter [:load_user_from_param, :load_permissions_for_user], :only => [:show, :edit, :update, :destroy, :reset_password, :process_reset_password, :verify]

  def create
		@user = User.new(params[:user])
		if @user.save
			set_logged_in(@user.id, false)
			redirect_to login_path
		else
      @submit_to = new_user_path
			render :edit
		end
  end

  def destroy
		# Only allow deleting if the user has permission.
		if @can_delete
			@page[:title] = t(:title_user_delete)
			if User.destroy(@user.id): EventLog.create(:event_id => Event::USER_DELETED, :event_data => @user.id.to_s) end
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
      bolResult = false
      if @user.verification_code == ''
        @user.set_verification_code
        bolResult = @user.save
      else
        bolResult = @user.send_verification_email(true)
      end
      if bolResult
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
      @user.password_recovery_code_set = nil
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

  def search
    limit = StringLib.cast(params[:limit], :int)
    if limit == nil or limit <= 0: limit = Constant::get(:search_default_limit) end
    text = params[:text]
    if text == nil
      @users = User.find(:all, :limit => limit, :order => 'created_at DESC')
    else
      @users = User.find(:all, :limit => limit, :order => 'created_at DESC', :conditions => ['username LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR email LIKE ?', '%' + text + '%', '%' + text + '%', '%' + text + '%', '%' + text + '%'])
    end
    @page[:title] = t(:title_user_search)
    @page[:subtitle] = ''
  end

  def show
    error_page_on_fail @user != nil, :msg_user_not_found
  end

  def update
	  @user = User.find_by_id(params[:user][:id])
    load_permissions_for_user
    old_username = @user.username
	  unless @user == nil
      if @can_edit
			  if params[:user][:password] == ''
				  params[:user].delete(:password)
				  params[:user].delete(:password_confirmation)
			  end
			  if params[:user][:email] == '' or params[:user][:email].downcase == @user.email
				  params[:user].delete(:email)
				  params[:user].delete(:email_confirmation)
			  end
			  if @user.update_attributes(params[:user])
          flash[:notice] = t(:msg_profile_saved)
          @user.add_edited_event
				  redirect_to user_path(@user.username)
			  else
		      @submit_to = user_path(old_username)
				  render :edit
			  end
      else
			  redirect_to user_path(@user.username)
		  end
    end
  end

  def verify
    @verified = false
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
		if current_user_stub == nil or current_user_stub.id == nil or current_user_stub.id <= 0: redirect_to new_user_path end
		@page[:title] = t(:title_email_verification)
	end

	protected
	def set_page_vars
		@page[:subtitle] = t(:subtitle_users)
	end

end
