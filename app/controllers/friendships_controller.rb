class FriendshipsController < ApplicationController
	before_filter :logged_in_check, :except => :show
	before_filter [:load_user_from_param, :load_permissions_for_user]
  before_filter :load_friend, :only => [:block, :create, :destroy, :ignore]

  def block
    if @can_edit
      if @friend == nil or !@friend.friends.exists?(@user)
        flash.now[:error] = t(:msg_friend_not_found)
      else
        @friend.friendships.find_by_friend_id(@user.id).block
        flash.now[:notice] = t(:msg_friend_blocked)
        @action_completed = true
      end
    else
			flash.now[:error] = t(:msg_not_authorized)
    end
    render :edit_response
  end

  def create
    if @can_edit
      if @friend == nil
        flash.now[:error] = t(:msg_friend_not_found)
      else
        @user.add_friend(@friend)
        @friend_added = true
        flash.now[:notice] = t(:msg_friend_added)
        @action_completed = true
      end
    else
			flash.now[:error] = t(:msg_not_authorized)
    end
    render :edit_response
  end

  def destroy
    if @can_delete
      if @user.remove_friend(@friend)
        flash.now[:notice] = t(:msg_friend_deleted)
        @action_completed = true
      else
        flash.now[:error] = t(:msg_friend_not_found)
      end
    else
			flash.now[:error] = t(:msg_not_authorized)
    end
    render :edit_response
  end

  def ignore
    if @can_edit
      if @friend == nil or !@friend.friends.exists?(@user)
        flash.now[:error] = t(:msg_friend_not_found)
      else
        @friend.friendships.find_by_friend_id(@user.id).ignore
        flash.now[:notice] = t(:msg_friend_ignored)
        @action_completed = true
      end
    else
			flash.now[:error] = t(:msg_not_authorized)
    end
    render :edit_response
  end

  def show
  end

  protected
  def load_friend
    @friend = User.find_by_username(params[:friend])
    @friend_added = false
    @action_completed = false
  end

end
