require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  def test_create_group_membership
    do_login :user1
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_not_nil g
    assert u.friends.include?(u2)
    assert !g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :create, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_response :success
    assert_template :create
    assert_not_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_equal gm_count + 1, g.members.count
    assert_equal friend_count, u.friends.count
    assert g.members.include?(u2)
    assert_equal flash[:notice], I18n.t(:msg_group_membership_created, :friend_name => u2.full_name, :group_name => g.name)
    assert_select 'h1', I18n.t(:title_create_group_membership)
    assert_select "a[href=#{user_groups_path(u)}]", I18n.t(:link_back_to_groups)
    assert_select '.error_msg', ''
    assert_select '.notice_msg', I18n.t(:msg_group_membership_created, :friend_name => u2.full_name, :group_name => g.name)
  end

  def test_create_group_membership_new_friend
    do_login :user1
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user4).id)
    assert_not_nil u2
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_not_nil g
    assert !u.friends.include?(u2)
    assert !g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :create, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_response :success
    assert_template :create
    assert_not_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_equal gm_count + 1, g.members.count
    assert_equal friend_count + 1, u.friends.count
    assert g.members.include?(u2)
    assert_equal flash[:notice], I18n.t(:msg_group_membership_created, :friend_name => u2.full_name, :group_name => g.name)
    assert_select 'h1', I18n.t(:title_create_group_membership)
    assert_select "a[href=#{user_groups_path(u)}]", I18n.t(:link_back_to_groups)
    assert_select '.error_msg', ''
    assert_select '.notice_msg', I18n.t(:msg_group_membership_created, :friend_name => u2.full_name, :group_name => g.name)
  end

  def test_do_not_create_group_membership_for_self
    do_login :user1
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_not_nil g
    assert !u.friends.include?(u)
    assert !g.members.include?(u)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :create, :username => u.username, :group_name => g.group_name, :friend => u.username
    assert_response :success
    assert_template :create
    assert_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert !g.members.include?(u)
    assert_equal flash[:error], I18n.t(:msg_group_membership_not_created, :friend_name => u.full_name, :group_name => g.name)
    assert_select 'h1', I18n.t(:title_create_group_membership)
    assert_select "a[href=#{user_groups_path(u)}]", I18n.t(:link_back_to_groups)
    assert_select '.error_msg', I18n.t(:msg_group_membership_not_created, :friend_name => u.full_name, :group_name => g.name)
    assert_select '.notice_msg', ''
  end

  def test_do_not_create_group_membership_not_logged_in
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_not_nil g
    assert u.friends.include?(u2)
    assert !g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :create, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_redirected_to error_path
    assert_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert !g.members.include?(u2)
    assert_equal flash[:error], I18n.t(:msg_not_authorized)
  end

  def test_do_not_create_group_membership_group_does_not_exist_for_user
    do_login :user1
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user4).id)
    assert_not_nil u2
    g = Group.find_by_id(groups(:ryan_friends).id)
    assert_not_nil g
    assert !u.friends.include?(u2)
    assert !u.groups.include?(g)
    assert !g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :create, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_redirected_to error_path
    assert_nil assigns(:group_membership)
    g = Group.find_by_id(groups(:ryan_friends).id)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert !g.members.include?(u2)
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
  end

  def test_do_not_create_group_membership_friend_does_not_exist
    do_login :user1
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_nil User.find_by_username(users(:user2).username + 'xx')
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_not_nil g
    friend_count = u.friends.count
    gm_count = g.members.count
    get :create, :username => u.username, :group_name => g.group_name, :friend => users(:user2).username + 'xx'
    assert_redirected_to error_path
    assert_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert_nil User.find_by_username(users(:user2).username + 'xx')
    assert_equal flash[:error], I18n.t(:msg_friend_not_found)
  end

  def test_ajax_add_group_membership
    do_login :user1
    xhr :get, :create, { :username => users(:user1).username, :group_name => groups(:user1_family).group_name, :friend => users(:user2).username }
    assert_jquery_notice I18n.t(:msg_group_membership_created, :friend_name => users(:user2).first_name + ' ' + users(:user2).last_name, :group_name => groups(:user1_family).name)
    # This could use some checking of the inserted js "if" statements here.
    assert_jquery '#group_memberships_for_' + users(:user2).username, 'append', user_group_remove_member_path(:username => users(:user1).username, :group_name => groups(:user1_family).group_name, :friend => users(:user2).username)
    assert_jquery '#group_members_' + groups(:user1_family).group_name, 'append', user_group_remove_member_path(:username => users(:user1).username, :group_name => groups(:user1_family).group_name, :friend => users(:user2).username)
  end

  def test_ajax_do_not_add_group_membership_not_logged_in
    xhr :get, :create, { :username => users(:user1).username, :group_name => groups(:user1_family).group_name, :friend => users(:user2).username }
    assert_jquery_error :msg_not_authorized
  end

  def test_destroy_group_membership
    do_login :ryan
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    assert u.friends.include?(u2)
    assert g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    # Check group with same name
    u3 = User.find_by_id(users(:user6).id)
    assert_not_nil u3
    g2 = u3.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g2
    assert g2.members.include?(u2)
    gm_count2 = g2.members.count
    get :destroy, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_response :success
    assert_template :destroy
    assert_not_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal gm_count - 1, g.members.count
    assert_equal friend_count, u.friends.count
    assert !g.members.include?(u2)
    g2 = u3.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal gm_count2, g2.members.count
    assert g2.members.include?(u2)
    assert_equal flash[:notice], I18n.t(:msg_group_membership_removed, :friend_name => u2.full_name, :group_name => g.name)
    #assert_select 'h1', I18n.t(:title_user_group, :group_name => g.name, :user_name => u.full_name)
    assert_select "a[href=#{user_groups_path(u)}]", I18n.t(:link_back_to_groups)
    assert_select '.error_msg', ''
    assert_select '.notice_msg', I18n.t(:msg_group_membership_removed, :friend_name => u2.full_name, :group_name => g.name)
  end

  def test_destroy_group_membership_not_a_member
    do_login :ryan
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    g = u.groups.find_by_group_name(groups(:ryan_friends).group_name)
    assert_not_nil g
    assert u.friends.include?(u2)
    assert !g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :destroy, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_response :success
    assert_template :destroy
    assert_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:ryan_friends).group_name)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert !g.members.include?(u2)
    assert_equal flash[:notice], I18n.t(:msg_group_membership_removed, :friend_name => u2.full_name, :group_name => g.name)
    #assert_select 'h1', I18n.t(:title_user_group, :group_name => g.name, :user_name => u.full_name)
    assert_select "a[href=#{user_groups_path(u)}]", I18n.t(:link_back_to_groups)
    assert_select '.error_msg', ''
    assert_select '.notice_msg', I18n.t(:msg_group_membership_removed, :friend_name => u2.full_name, :group_name => g.name)
  end

  def test_do_not_destroy_group_membership_not_logged_in
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    assert u.friends.include?(u2)
    assert g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :destroy, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_redirected_to error_path
    assert_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert g.members.include?(u2)
    assert_equal flash[:error], I18n.t(:msg_not_authorized)
  end

  def test_do_not_destroy_group_membership_group_does_not_exist_for_user
    do_login :user7
    u = User.find_by_id(users(:user7).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    assert u.friends.include?(u2)
    assert !u.groups.include?(g)
    assert g.members.include?(u2)
    friend_count = u.friends.count
    gm_count = g.members.count
    get :destroy, :username => u.username, :group_name => g.group_name, :friend => u2.username
    assert_redirected_to error_path
    assert_nil assigns(:group_membership)
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert g.members.include?(u2)
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
  end

  def test_do_not_destroy_group_membership_friend_does_not_exist
    do_login :user1
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_nil User.find_by_username(users(:user2).username + 'xx')
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_not_nil g
    friend_count = u.friends.count
    gm_count = g.members.count
    get :destroy, :username => u.username, :group_name => g.group_name, :friend => users(:user2).username + 'xx'
    assert_redirected_to error_path
    assert_nil assigns(:group_membership)
    g = u.groups.find_by_group_name(groups(:user1_family).group_name)
    assert_equal gm_count, g.members.count
    assert_equal friend_count, u.friends.count
    assert_nil User.find_by_username(users(:user2).username + 'xx')
    assert_equal flash[:error], I18n.t(:msg_friend_not_found)
  end

  def test_ajax_destroy_group_membership
    do_login :ryan
    xhr :get, :destroy, { :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name, :friend => users(:user1).username }
    assert_jquery "#group_membership_#{assigns(:group_membership).id}", 'remove'
    assert_jquery ".user_row_#{assigns(:group_membership).friend.id}", 'remove'
    # This needs a test of the inserted js/prototype code here, but this testing suite can't handle it.
    assert_jquery_notice I18n.t(:msg_group_membership_removed, :friend_name => users(:user1).first_name + ' ' + users(:user1).last_name, :group_name => groups(:ryan_family).name)
  end

  def test_ajax_do_not_destroy_group_membership_not_logged_in
    xhr :get, :destroy, { :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name, :friend => users(:user1).username }
    assert_jquery_error :msg_not_authorized
  end

end
