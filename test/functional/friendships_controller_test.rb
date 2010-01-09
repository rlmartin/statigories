require 'test_helper'

class FriendshipsControllerTest < ActionController::TestCase
  def test_block_friendship
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    do_login :user2
    # Look at the other user's page
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
    # Do the block
    get :block, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.notice_msg", I18n.t(:msg_friend_blocked)
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert f.blocked
    assert f.responded
    assert u.friends.count, friend_count
    # Look at the other user's page again
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", :count => 0
  end

  def test_do_not_block_friendship_friend_not_found
    u = User.find_by_id(users(:ryan).username + 'xx')
    assert_nil u
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    do_login :user2
    # Do the block
    get :block, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_friend_not_found)
    assert u.friends.count, friend_count
  end

  def test_do_not_block_friendship_not_logged_in
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    # Look at the other user's page
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
    # Do the block
    get :block, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_not_authorized)
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert !f.responded
    assert u.friends.count, friend_count
    # Look at the other user's page again
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
  end

  def test_create_friendship
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert !f.responded
    do_login :user2
    # Look at the other user's page
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
    # Do the create
    get :create, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.notice_msg", I18n.t(:msg_friend_added)
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert f.responded
    assert u.friends.count, friend_count + 1
    # Look at own page
    get :show, { :username => users(:user2).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:ryan).username)}]", users(:ryan).first_name + ' ' + users(:ryan).last_name
    # Look at the other user's page again
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
  end

  def test_do_not_create_friendship_friend_not_found
    u = User.find_by_id(users(:ryan).username + 'xx')
    assert_nil u
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    do_login :user2
    # Do the create
    get :create, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_friend_not_found)
    assert u.friends.count, friend_count
  end

  def test_do_not_create_friendship_not_logged_in
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert !f.responded
    # Look at the other user's page
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
    # Do the create
    get :create, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_not_authorized)
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert !f.responded
    assert u.friends.count, friend_count
    # Look at the other user's page again
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
  end

  def test_destroy_friendship
    u = User.find_by_id(users(:user3).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:user1).id)
    assert_not_nil f
    assert !f.blocked
    assert f.responded
    do_login :user3
    # Look at own page
    get :show, { :username => users(:user3).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user1).username)}]", users(:user1).first_name + ' ' + users(:user1).last_name
    # Look at the other user's page
    get :show, { :username => users(:user1).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user3).username)}]", users(:user3).first_name + ' ' + users(:user3).last_name
    # Do the destroy
    get :destroy, { :username => users(:user3).username, :friend => users(:user1).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.notice_msg", I18n.t(:msg_friend_deleted)
    f = u.inverse_friendships.find_by_user_id(users(:user1).id)
    assert_not_nil f
    assert !f.blocked
    assert f.responded
    assert u.friends.count, friend_count - 1
    assert_nil u.friendships.find_by_friend_id(users(:user1).id)
    # Look at own page again
    get :show, { :username => users(:user3).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user1).username)}]", :count => 0
    # Look at the other user's page again
    get :show, { :username => users(:user1).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user3).username)}]", users(:user3).first_name + ' ' + users(:user3).last_name
  end

  def test_do_not_destroy_friendship_friend_not_found
    u = User.find_by_id(users(:user1).username + 'xx')
    assert_nil u
    u = User.find_by_id(users(:user3).id)
    assert_not_nil u
    friend_count = u.friends.count
    do_login :user3
    # Do the destroy
    get :destroy, { :username => users(:user3).username, :friend => users(:user1).username + 'xx' }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_friend_not_found)
    assert u.friends.count, friend_count
  end

  def test_do_not_destroy_friendship_not_logged_in
    u = User.find_by_id(users(:user3).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:user1).id)
    assert_not_nil f
    assert !f.blocked
    assert f.responded
    # Look at own page
    get :show, { :username => users(:user3).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user1).username)}]", users(:user1).first_name + ' ' + users(:user1).last_name
    # Look at the other user's page
    get :show, { :username => users(:user1).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user3).username)}]", users(:user3).first_name + ' ' + users(:user3).last_name
    # Do the destroy
    get :destroy, { :username => users(:user3).username, :friend => users(:user1).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_not_authorized)
    f = u.inverse_friendships.find_by_user_id(users(:user1).id)
    assert_not_nil f
    assert !f.blocked
    assert f.responded
    assert u.friends.count, friend_count
    # Look at own page again
    get :show, { :username => users(:user3).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user1).username)}]", users(:user1).first_name + ' ' + users(:user1).last_name
    # Look at the other user's page again
    get :show, { :username => users(:user1).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user3).username)}]", users(:user3).first_name + ' ' + users(:user3).last_name
  end

  def test_ignore_friendship
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.responded
    # Look at the other user's page
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
    # Do the ignore
    do_login :user2
    get :ignore, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.notice_msg", I18n.t(:msg_friend_ignored)
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert f.responded
    assert !f.blocked
    assert u.friends.count, friend_count
    # Look at the other user's page again
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
  end

  def test_do_not_ignore_friendship_friend_not_found
    u = User.find_by_id(users(:ryan).username + 'xx')
    assert_nil u
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    do_login :user2
    # Do the block
    get :ignore, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_friend_not_found)
    assert u.friends.count, friend_count
  end

  def test_do_not_ignore_friendship_not_logged_in
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert !f.responded
    # Look at the other user's page
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
    # Do the ignore
    get :ignore, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_response :success
    assert_template :edit_response
    assert_select "div.error_msg", I18n.t(:msg_not_authorized)
    f = u.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil f
    assert !f.blocked
    assert !f.responded
    assert u.friends.count, friend_count
    # Look at the other user's page again
    get :show, { :username => users(:ryan).username }
    assert_response :success
    assert_select ".user_row a[href=#{user_path(users(:user2).username)}]", users(:user2).first_name + ' ' + users(:user2).last_name
  end

  def test_show_own_page_with_friend_requests
    do_login :user2
    get :show, { :username => users(:user2).username }
    assert_select "h3", :count => 2
    assert_select "h3:nth-of-type(1)", I18n.t(:section_title_user_friend_requests)
    assert_select "h3:nth-of-type(2)", I18n.t(:section_title_user_friends)
    assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:user2).username, :friend => users(:ryan).username)}]", I18n.t(:link_add_friend)
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:user2).username, :friend => users(:ryan).username)}]", I18n.t(:link_block_friend_request)
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:user2).username, :friend => users(:ryan).username)}]", I18n.t(:link_ignore_friend_request)
  end

  def test_show_own_page_with_no_friend_requests
    do_login :ryan
    get :show, { :username => users(:ryan).username }
    assert_select "h3", :count => 0
    assert_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => '')}]" do |elements|
      elements.each do |element|
        assert !element.match(:child => I18n.t(:link_add_friend))
      end
    end
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => '')}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => '')}]", :count => 0
  end

  def test_show_page_with_friend_requests_not_logged_in
    get :show, { :username => users(:user2).username }
    assert_select "h3", :count => 0
    css_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => '')}]" do |elements|
      elements.each do |element|
        assert !element.match(:child => I18n.t(:link_add_friend))
      end
    end
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => '')}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => '')}]", :count => 0
  end

  def test_show_page_with_friend_requests_other_user
    do_login :user3
    get :show, { :username => users(:user2).username }
    assert_select "h3", :count => 0
    css_select ".friend_action a[onclick*=#{user_add_friend_path(:username => users(:ryan).username, :friend => '')}]" do |elements|
      elements.each do |element|
        assert !element.match(:child => I18n.t(:link_add_friend))
      end
    end
    assert_select ".friend_action a[onclick*=#{user_block_friend_path(:username => users(:ryan).username, :friend => '')}]", :count => 0
    assert_select ".friend_action a[onclick*=#{user_ignore_friend_path(:username => users(:ryan).username, :friend => '')}]", :count => 0
  end

  def test_ajax_add_friendship
    do_login :user2
    xhr :get, :create, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'friendship_' + users(:ryan).id.to_s do |elements|
      assert_select "span", I18n.t(:link_delete_friend)
    end
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", ''
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_added)
    end
    assert_select_rjs :insert, :bottom, 'friend_list'
    # If I ever integrate better RJS testing, add these tests:
    # assert_select_rjs :hide, '.user_row'.each
  end

  def test_ajax_do_not_add_friendship_invalid_friend
    assert_nil User.find_by_username(users(:ryan).username + 'xx')
    do_login :user2
    xhr :get, :create, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_add_friendship_friend_not_specified
    do_login :user2
    xhr :get, :create, { :username => users(:user2).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_add_friendship_not_logged_in
    xhr :get, :create, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_not_authorized)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_block_friendship
    do_login :user2
    xhr :get, :block, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'friendship_' + users(:ryan).id.to_s do |elements|
      assert_select "span", I18n.t(:link_add_friend)
    end
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", ''
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_blocked)
    end
    # If I ever integrate better RJS testing, add these tests:
    # !assert_select_rjs :insert, :bottom, 'friend_list'
    # assert_select_rjs :hide, '.user_row'.each
  end

  def test_ajax_do_not_block_friendship_invalid_friend
    assert_nil User.find_by_username(users(:ryan).username + 'xx')
    do_login :user2
    xhr :get, :block, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_block_friendship_friend_not_specified
    do_login :user2
    xhr :get, :block, { :username => users(:user2).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_block_friendship_not_logged_in
    xhr :get, :block, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_not_authorized)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_delete_friendship
    assert_not_nil Friendship.find_by_friend_id_and_user_id(users(:user2).id, users(:ryan).id)
    do_login :ryan
    xhr :get, :destroy, { :username => users(:ryan).username, :friend => users(:user2).username }
    assert_select_rjs :chained_replace_html, 'friendship_' + users(:user2).id.to_s do |elements|
      assert_select "span", I18n.t(:link_add_friend)
    end
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", ''
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_deleted)
    end
    # If I ever integrate better RJS testing, add these tests:
    # !assert_select_rjs :insert, :bottom, 'friend_list'
    # assert_select_rjs :hide, '.user_row'.each
  end

  def test_ajax_do_not_delete_friendship_invalid_friend
    assert_nil User.find_by_username(users(:ryan).username + 'xx')
    do_login :user2
    xhr :get, :destroy, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_delete_friendship_friend_not_specified
    do_login :user2
    xhr :get, :destroy, { :username => users(:user2).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_delete_friendship_not_logged_in
    xhr :get, :destroy, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_not_authorized)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_ignore_friendship
    do_login :user2
    xhr :get, :ignore, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'friendship_' + users(:ryan).id.to_s do |elements|
      assert_select "span", I18n.t(:link_add_friend)
    end
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", ''
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_ignored)
    end
    # If I ever integrate better RJS testing, add these tests:
    # !assert_select_rjs :insert, :bottom, 'friend_list'
    # assert_select_rjs :hide, '.user_row'.each
  end

  def test_ajax_do_not_ignore_friendship_invalid_friend
    assert_nil User.find_by_username(users(:ryan).username + 'xx')
    do_login :user2
    xhr :get, :ignore, { :username => users(:user2).username, :friend => users(:ryan).username + 'xx' }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_ignore_friendship_friend_not_specified
    do_login :user2
    xhr :get, :ignore, { :username => users(:user2).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_friend_not_found)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

  def test_ajax_do_not_ignore_friendship_not_logged_in
    xhr :get, :ignore, { :username => users(:user2).username, :friend => users(:ryan).username }
    assert_select_rjs :chained_replace_html, 'error_msg' do |elements|
      assert_select "span", I18n.t(:msg_not_authorized)
    end
    assert_select_rjs :chained_replace_html, 'notice_msg' do |elements|
      assert_select "span", ''
    end
  end

end
