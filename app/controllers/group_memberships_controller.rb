class GroupMembershipsController < ApplicationController
	before_filter :load_user_from_param, :load_permissions_for_user, :load_group_from_param, :load_friend_from_param
  before_filter :check_authorization_delete, :only => [:destroy]
  before_filter :check_authorization_edit, :only => [:create]

  def create
    unless error_page_on_fail @friend != nil, :msg_friend_not_found
      unless error_page_on_fail @group != nil, :msg_group_not_found
        @group_membership = @user.add_friend_to_group(@friend, @group)
        if @group_membership == nil or @group_membership.id == nil
          flash[:error] = t(:msg_group_membership_not_created, :friend_name => @friend.full_name, :group_name => @group.name)
        else
          flash[:notice] = t(:msg_group_membership_created, :friend_name => @friend.full_name, :group_name => @group.name)
          @success = true
        end
      end
    end
    render :create unless performed?
  end

  def destroy
    unless error_page_on_fail @friend != nil, :msg_friend_not_found
      unless error_page_on_fail @group != nil, :msg_group_not_found
        @group_membership = @user.remove_friend_from_group(@friend, @group)
        flash[:notice] = t(:msg_group_membership_removed, :friend_name => @friend.full_name, :group_name => @group.name)
        @success = true
      end
    end
    render :destroy unless performed?
  end

  protected
  def load_friend_from_param
    @friend = nil
    @friend = User.find_by_username(params[:friend]) unless params[:friend] == nil
  end
end
