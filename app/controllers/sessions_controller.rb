class SessionsController < ApplicationController
	include StringLib

  def new
		@page[:title] = t(:title_login)
		if StringLib.cast(session[:logged_in], :bool): redirect_to '/' end
  end

  def create
		@page[:title] = t(:title_login)
		params[:password] = Digest::MD5.hexdigest(params[:password])
		@current_user = User.find_by_email_and_password(params[:email], params[:password])
		if @current_user
			set_logged_in(@current_user.id, params[:remember_me])
			redirect_to '/'
		else
			flash.now[:error] = t(:msg_invalid_login)
			render :action => 'new'
		end
  end

  def destroy
		@page[:title] = t(:title_logout)
		logout
  end

end
