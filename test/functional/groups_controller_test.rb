require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  def test_should_show_all_user_groups
    do_login :ryan
    get :show_all, :username => users(:ryan).username
    assert_response :success
    assert_template :show_all
    assert_not_nil assigns(:user)
    # Has correct title text
    assert_select "h1", I18n.t(:title_user_groups, :name => assigns(:user).full_name)
    assert_select "li.group_row", :count => assigns(:user).groups.count
    assert_select "li.group_row a[href=#{user_group_path(:username => users(:ryan).username, :group_name => groups(:ryan_family).group_name)}]", groups(:ryan_family).name + ' (' + Group.find_by_id(groups(:ryan_family).id).members.count.to_s + ')'
    assert_select "li.group_row .group_actions a[href=#{user_remove_group_path(:username => users(:ryan).username, :group_name => groups(:ryan_family).group_name)}][data-method=delete][data-remote=true]", I18n.t(:link_delete_group)
  end

  def test_should_show_all_user_groups_no_groups
    do_login :user4
    get :show_all, :username => users(:user4).username
    assert_response :success
    assert_template :show_all
    assert_not_nil assigns(:user)
    # Has correct title text
    assert_select "h1", I18n.t(:title_user_groups, :name => assigns(:user).full_name)
    assert_select "li.group_row", :count => 0
    assert_select ".notice_msg", I18n.t(:msg_no_groups_found)
  end

  def test_should_not_show_all_user_groups_not_logged_in
    get :show_all, :username => users(:ryan).username
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_view_groups_no_access)
  end

  def test_should_not_show_all_user_groups_user_not_found
    assert_nil User.find_by_username(users(:ryan).username + 'xx')
    get :show_all, :username => users(:ryan).username + 'xx'
    assert_nil assigns(:user)
    assert_redirected_to user_path(users(:ryan).username + 'xx')
  end

  def test_should_show_group_members
    do_login :ryan
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + groups(:ryan_family).name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", assigns(:group).name
    assert_select "a", I18n.t(:link_rename)
    assert_select ".user_row", :count => assigns(:group).members.count
    # Check add friend dropdown - empty (all friends already in this group)
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}]", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}][data-remote=true]", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}] input[type=hidden][value=#{groups(:ryan_family).group_name}]", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}] select option", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}] select option[value='']", I18n.t(:input_add_friend_to_group)
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}] input[type=submit][value=#{I18n.t(:btn_add)}]", :count => 1
  end

  def test_should_show_group_members_no_members
    g = Group.find_by_id(groups(:user2_family).id)
    assert_not_nil g
    assert_equal 0, g.members.count
    do_login :user2
    get :show, :username => users(:user2).username, :group_name => groups(:user2_family).group_name
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + groups(:ryan_family).name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", assigns(:group).name
    assert_select "a", I18n.t(:link_rename)
    assert_select ".notice_msg", I18n.t(:msg_group_members_not_found)
    assert_select ".user_row", :count => 0
    # Check add friend dropdown - full (no friends already in this group)
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}]", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}][data-remote=true]", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}] input[type=hidden][value=#{groups(:user2_family).group_name}]", :count => 1
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}] select option", :count => 2
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}] select option[value='']", I18n.t(:input_add_friend_to_group)
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}] select option[value='#{users(:user4).username}']", users(:user4).full_name
    assert_select "form[action=#{user_group_add_member_dynamic_path(:username => users(:user2).username)}] input[type=submit][value=#{I18n.t(:btn_add)}]", :count => 1
  end

  def test_should_not_show_group_members_not_logged_in
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_view_groups_no_access)
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
  end

  def test_should_not_show_group_members_different_user
    do_login :user1
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_view_groups_no_access)
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
  end

  def test_should_show_group_not_found
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + 'x')
    do_login :ryan
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + 'x'
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
    assert_not_nil assigns(:user)
    assert_nil assigns(:group)
  end

  def test_should_show_group_not_found_not_logged_in
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + 'x')
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + 'x'
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_view_groups_no_access)
    assert_not_nil assigns(:user)
    assert_nil assigns(:group)
  end

  def test_should_show_group_not_found_other_user
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + 'x')
    do_login :user1
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + 'x'
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_view_groups_no_access)
    assert_not_nil assigns(:user)
    assert_nil assigns(:group)
  end

  def test_should_delete_group_by_group_name
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    do_login :ryan
    get :destroy, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    assert_select "h1", I18n.t(:title_delete_group)
    assert_select ".notice_msg", I18n.t(:msg_group_deleted)
    assert_select ".error_msg", ''
    assert_select "a[href=#{user_groups_path(users(:ryan).username)}]", I18n.t(:link_back_to_groups)
  end

  def test_should_delete_group_by_name
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    do_login :ryan
    get :destroy, :username => users(:ryan).username, :group_name => groups(:ryan_family).name
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    assert_select "h1", I18n.t(:title_delete_group)
    assert_select ".notice_msg", I18n.t(:msg_group_deleted)
    assert_select ".error_msg", ''
    assert_select "a[href=#{user_groups_path(users(:ryan).username)}]", I18n.t(:link_back_to_groups)
  end

  def test_should_not_delete_group_by_group_name_other_user
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    do_login :user1
    get :destroy, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_not_authorized)
  end

  def test_should_not_delete_group_by_group_name_not_logged_in
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    get :destroy, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_equal 0, GroupMembership.find(:all, :conditions => {:group_id => groups(:ryan_family).id}).count
    assert_redirected_to error_path
    assert_equal flash[:error], I18n.t(:msg_not_authorized)
  end

  def test_ajax_delete_group
    assert_not_nil Group.find_by_id(groups(:ryan_family).id)
    do_login :ryan
    xhr :get, :destroy, { :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name }
    assert_jquery_notice :msg_group_deleted
    assert_jquery ".group_row_#{groups(:ryan_family).id}", 'remove'
  end

  def test_ajax_do_not_delete_group_group_not_for_user
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + 'xx')
    do_login :ryan
    xhr :get, :destroy, { :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + 'xx' }
    assert_jquery_error :msg_group_not_found
  end

  def test_ajax_do_not_delete_group_group_not_specified
    do_login :ryan
    xhr :get, :destroy, { :username => users(:ryan).username }
    assert_jquery_error :msg_group_not_found
  end

  def test_ajax_do_not_delete_group_not_logged_in
    xhr :get, :destroy, { :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name }
    assert_jquery_error :msg_not_authorized
  end

  def test_should_create_group
    u = User.find_by_id(users(:ryan).id)
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    num_groups = u.groups.count
    do_login :ryan
    get :create, :username => users(:ryan).username, :name => groups(:ryan_family).name + ' XX'
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    assert_equal 0, GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_redirected_to user_group_path(:username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx')
    assert_equal flash[:notice], I18n.t(:msg_group_created)
    assert_nil flash[:error]
    assert_equal num_groups + 1, u.groups.count
    # Check the page
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx'
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + g.name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", g.name
    assert_select ".notice_msg", I18n.t(:msg_group_members_not_found)
    assert_select ".user_row", :count => 0
  end

  def test_should_not_create_group_not_logged_in
    u = User.find_by_id(users(:ryan).id)
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    num_groups = u.groups.count
    get :create, :username => users(:ryan).username, :name => groups(:ryan_family).name + ' XX'
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_not_authorized)
    assert_equal num_groups, u.groups.count
    # Check the page
    do_login :ryan
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx'
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
  end

  def test_should_not_create_group_other_user
    u = User.find_by_id(users(:ryan).id)
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    num_groups = u.groups.count
    do_login :user3
    get :create, :username => users(:ryan).username, :name => groups(:ryan_family).name + ' XX'
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_not_authorized)
    assert_equal num_groups, u.groups.count
    # Check the page
    do_login :ryan
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx'
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
  end

  def test_should_not_create_group_missing_name
    u = User.find_by_id(users(:ryan).id)
    num_groups = u.groups.count
    do_login :ryan
    # Check the show all page
    get :show_all, :username => users(:ryan).username
    assert_response :success
    assert_template :show_all
    assert_select "li.group_row", :count => num_groups
    get :create, :username => users(:ryan).username
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_invalid_group_name)
    assert_equal num_groups, u.groups.count
    # Check the show all page
    get :show_all, :username => users(:ryan).username
    assert_select "li.group_row", :count => num_groups
  end

  def test_should_not_create_group_already_exists
    u = User.find_by_id(users(:ryan).id)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    num_groups = u.groups.count
    num_members = GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_not_equal num_members, 0
    do_login :ryan
    get :create, :username => users(:ryan).username, :name => groups(:ryan_family).name
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal num_members, GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_redirected_to user_group_path(:username => users(:ryan).username, :group_name => groups(:ryan_family).group_name)
    assert_equal flash[:error], I18n.t(:msg_group_already_exists)
    assert_nil flash[:notice]
    assert_equal num_groups, u.groups.count
    # Check the page
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + g.name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", g.name
    assert_select ".user_row", :count => num_members
  end

  def test_should_edit_group_name_same_name
    u = User.find_by_id(users(:ryan).id)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    num_groups = u.groups.count
    num_members = GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_not_equal num_members, 0
    do_login :ryan
    # Check the page
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + g.name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", g.name
    assert_select ".user_row", :count => num_members
    # Do the edit
    get :create, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name, :name => groups(:ryan_family).name
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_equal num_members, GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_redirected_to user_group_path(:username => users(:ryan).username, :group_name => groups(:ryan_family).group_name)
    assert_equal flash[:notice], I18n.t(:msg_group_edited)
    assert_nil flash[:error]
    assert_equal num_groups, u.groups.count
    # Check the page
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + g.name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", g.name
    assert_select ".user_row", :count => num_members
  end

  def test_should_edit_group_name
    u = User.find_by_id(users(:ryan).id)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    num_groups = u.groups.count
    num_members = GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_not_equal num_members, 0
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    do_login :ryan
    # Check the page
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + g.name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", g.name
    assert_select ".user_row", :count => num_members
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx'
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
    flash[:error] = nil
    # Do the edit
    get :create, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name, :name => groups(:ryan_family).name + ' XX'
    assert_nil u.groups.find_by_group_name(groups(:ryan_family).group_name)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name + '_xx')
    assert_equal num_members, GroupMembership.find(:all, :conditions => {:group_id => g.id}).count
    assert_redirected_to user_group_path(:username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx')
    assert_equal flash[:notice], I18n.t(:msg_group_edited)
    assert_nil flash[:error]
    assert_equal num_groups, u.groups.count
    # Check the page
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name + '_xx'
    assert_response :success
    assert_template :show
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:group)
    # Has correct title text
    assert_select_match_text "title", '^' + g.name + ' :'
    assert_select_match_text "h1", assigns(:user).full_name
    assert_select_match_text "h1", g.name
    assert_select ".user_row", :count => num_members
    get :show, :username => users(:ryan).username, :group_name => groups(:ryan_family).group_name
    assert_redirected_to error_path
    assert_nil flash[:notice]
    assert_equal flash[:error], I18n.t(:msg_group_not_found)
  end

  def test_form_add_to_html
    do_login :ryan
    xhr :get, :form_add_to, { :username => users(:ryan).username, :friend => users(:user1).username }
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\"", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*data-remote=\\\\\"true\\\\\"", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*>.*<select .*name=\\\\\"group_name\\\\\"", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*>.*<select .*name=\\\\\"group_name\\\\\".*>.*<option .*value=\\\\\"#{groups(:ryan_family).group_name}\\\\\".*>#{groups(:ryan_family).name}<", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*>.*<select .*name=\\\\\"group_name\\\\\".*>.*<option .*value=\\\\\"#{groups(:ryan_friends).group_name}\\\\\".*>#{groups(:ryan_friends).name}<", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*>.*<select .*name=\\\\\"group_name\\\\\".*>.*<option .*value=\\\\\"#{groups(:ryan_work).group_name}\\\\\".*>#{groups(:ryan_work).name}<", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*>.*<input .*type=\\\\\"hidden\\\\\".*name=\\\\\"friend\\\\\".*value=\\\\\"#{users(:user1).username}\\\\\"", false, false, false
    assert_jquery "#group_form_add_to_#{users(:user1).username}", 'html', "form .*action=\\\\\"#{user_group_add_member_dynamic_path(:username => users(:ryan).username)}\\\\\".*>.*<input .*type=\\\\\"submit\\\\\".*value=\\\\\"#{I18n.t(:btn_add)}\\\\\"", false, false, false
    # Tests of the form submit continue in the tests of the group_memberships controller.
  end

end

