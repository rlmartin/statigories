class OauthClientsController < ApplicationController
  before_filter :login_required
  before_filter :get_client_application, :only => [:show, :edit, :update, :destroy]
  
  def index
    @client_applications = current_user.client_applications
    @tokens = current_user.tokens.where('oauth_tokens.invalidated_at is null and oauth_tokens.authorized_at is not null')
  end

  def new
    @client_application = ClientApplication.new
  end

  def create
    @client_application = current_user.client_applications.build(params[:client_application])
    if @client_application.save
      flash[:notice] = t(:msg_oauth_client_saved)
      redirect_to :action => "show", :id => @client_application.id
    else
      flash[:error] = t(:msg_oauth_client_not_saved)
      render :action => "new"
    end
  end
  
  def show
  end

  def edit
  end
  
  def update
    if @client_application.update_attributes(params[:client_application])
      flash[:notice] = t(:msg_oauth_client_updated)
      redirect_to :action => "show", :id => @client_application.id
    else
      render :action => "edit"
    end
  end

  def destroy
    @client_application.destroy
    flash[:notice] = t(:msg_oauth_client_deleted)
    redirect_to :action => "index"
  end
  
  private
  def get_client_application
    error_page_on_fail @client_application = current_user.client_applications.find_by_id(params[:id]), :msg_not_authorized
  end
end
