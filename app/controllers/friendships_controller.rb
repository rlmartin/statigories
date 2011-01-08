class FriendshipsController < ApplicationController
	before_filter :logged_in_check, :except => :show
	before_filter [:load_user_from_param, :load_permissions_for_user]
  before_filter :load_friend, :only => [:block, :create, :destroy, :ignore]
  before_filter :check_authorization_delete, :only => [:destroy]
  before_filter :check_authorization_edit, :only => [:block, :create, :ignore]

  def block
    if @friend == nil or !@friend.friends.exists?(@user)
      flash.now[:error] = t(:msg_friend_not_found)
    else
      @friend.friendships.find_by_friend_id(@user.id).block
      flash.now[:notice] = t(:msg_friend_blocked)
      @success = true
    end
    render :edit_response
  end

  def create
    if @friend == nil
      flash.now[:error] = t(:msg_friend_not_found)
    else
      @user.add_friend(@friend)
      @friend_added = true
      flash.now[:notice] = t(:msg_friend_added)
      @success = true
    end
    render :edit_response unless performed?
  end

  def destroy
    if @user.remove_friend(@friend)
      flash.now[:notice] = t(:msg_friend_deleted)
      @success = true
    else
      flash.now[:error] = t(:msg_friend_not_found)
    end
    render :edit_response unless performed?
  end

  def ignore
    if @friend == nil or !@friend.friends.exists?(@user)
      flash.now[:error] = t(:msg_friend_not_found)
    else
      @friend.friendships.find_by_friend_id(@user.id).ignore
      flash.now[:notice] = t(:msg_friend_ignored)
      @success = true
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
