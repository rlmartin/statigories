class SessionsController < ApplicationController
	include StringLib

  def new
		@page[:title] = Constant::get(:title_login)
		if StringLib.cast(session[:logged_in], :bool): redirect_to '/' end
		flash[:error] = ''
  end

  def create
		@page[:title] = Constant::get(:title_login)
		params[:password] = Digest::MD5.hexdigest(params[:password])
		@current_user = User.find_by_email_and_password(params[:email], params[:password])
		if @current_user
			set_logged_in(@current_user.id, params[:remember_me])
			redirect_to '/'
		else
			flash.now[:error] = Constant::get(:error_invalid_login)
			render :action => 'new'
		end
  end

  def destroy
		@page[:title] = Constant::get(:title_logout)
		logout
  end

end
