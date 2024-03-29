class GroupsController < ApplicationController
	before_filter :load_user_from_param, :load_permissions_for_user, :load_group_from_param
  before_filter :check_authorization_delete, :only => [:destroy]
  before_filter :check_authorization_edit, :only => [:create]
  before_filter :check_authorization_view_for_groups, :only => [:form_add_to, :show_all, :show]

  def create
    if params[:group_name] == nil
      @group = @user.groups.find_by_name(params[:name])
    else
      @group = @user.groups.find_by_group_name(params[:group_name])
    end
    if @group == nil
      unless error_page_on_fail((params[:name] != nil and params[:name] != ''), :msg_invalid_group_name)
        @group = @user.groups.create(:name => params[:name])
        flash[:notice] = t(:msg_group_created)
      end
    elsif params[:name] != nil and params[:name] != '' and params[:group_name] != nil and params[:group_name] != ''
      @group.update_attributes(:name => params[:name])
      flash[:notice] = t(:msg_group_edited)
    else
      flash[:error] = t(:msg_group_already_exists)
    end
    redirect_to user_group_path(:username => @group.user.username, :group_name => @group.group_name) unless performed?
  end

  def destroy
    if params[:group_name] == nil
      @group = @user.groups.find_by_name(params[:name])
    else
      @group = @user.groups.find_by_group_name(params[:group_name])
    end
    if @group == nil
      flash.now[:error] = t(:msg_group_not_found)
    else
      @group.destroy
      flash.now[:notice] = t(:msg_group_deleted)
      @success = true
    end
    @page[:title] = t(:title_delete_group)
  end

  def form_add_to
#    if @can_view
      @success = true
#    else
#      error_page_on_fail @can_view, :msg_view_groups_no_access
#      flash[:error] = :msg_view_groups_no_access unless performed?
#    end
  end

  def show_all
  end

  def show
    error_page_on_fail @group != nil, :msg_group_not_found
  end

  protected
  def check_authorization_view_for_groups
    check_authorization_view :msg_view_groups_no_access
  end

end
