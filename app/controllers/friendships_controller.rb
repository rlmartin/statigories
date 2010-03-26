class FriendshipsController < ApplicationController
	before_filter :logged_in_check, :except => :show
	before_filter [:load_user_from_param, :load_permissions_for_user]
  before_filter :load_friend, :only => [:block, :create, :destroy, :ignore]

  def block
    unless error_page_on_fail @can_edit, :msg_not_authorized
      if @friend == nil or !@friend.friends.exists?(@user)
        flash.now[:error] = t(:msg_friend_not_found)
      else
        @friend.friendships.find_by_friend_id(@user.id).block
        flash.now[:notice] = t(:msg_friend_blocked)
        @success = true
      end
    end
    render :edit_response unless performed?
  end

  def create
    unless error_page_on_fail @can_edit, :msg_not_authorized
      if @friend == nil
        flash.now[:error] = t(:msg_friend_not_found)
      else
        @user.add_friend(@friend)
        @friend_added = true
        flash.now[:notice] = t(:msg_friend_added)
        @success = true
      end
    end
    render :edit_response unless performed?
  end

  def destroy
    unless error_page_on_fail @can_delete, :msg_not_authorized
      if @user.remove_friend(@friend)
        flash.now[:notice] = t(:msg_friend_deleted)
        @success = true
      else
        flash.now[:error] = t(:msg_friend_not_found)
      end
    end
    render :edit_response unless performed?
  end

  def ignore
    unless error_page_on_fail @can_edit, :msg_not_authorized
      if @friend == nil or !@friend.friends.exists?(@user)
        flash.now[:error] = t(:msg_friend_not_found)
      else
        @friend.friendships.find_by_friend_id(@user.id).ignore
        flash.now[:notice] = t(:msg_friend_ignored)
        @success = true
      end
    end
    render :edit_response unless performed?
  end

  def show
  end

  protected
  def load_friend
    @friend = User.find_by_username(params[:friend])
    @friend_added = false
    @success = false
  end

end
