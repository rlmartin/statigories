class SessionsController < ApplicationController
  def new
		if session[:user_id] == nil and cookies[:user_id] != nil and cookies[:user_id] != '': session[:user_id] = AESCrypt::decrypt(cookies[:user_id]).to_i end
		unless session[:user_id] == nil or session[:user_id] <= 0: redirect_to '/' end
  end

  def create
		params[:password] = Digest::MD5.hexdigest(params[:password])
		@current_user = User.find_by_email_and_password(params[:email], params[:password])
		if @current_user
			session[:user_id] = @current_user.id
			if params[:remember_me]: cookies[:user_id] = AESCrypt::encrypt(@current_user.id.to_s)
			else cookies[:user_id] = nil end
			redirect_to '/'
		else
			flash[:error_msg] = 'invalid'
			render :action => 'new'
		end
  end

  def destroy
		session[:user_id] = nil
		cookies[:user_id] = nil
  end

end
