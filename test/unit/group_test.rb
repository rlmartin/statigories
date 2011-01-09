require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  def test_associations
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    assert_equal g.user, User.find_by_id(users(:ryan).id)
    assert_equal g.group_memberships.count, 2
    assert_not_nil g.group_memberships.find_by_friendship_id(friendships(:ryan_user1).id)
    assert_equal g.friendships.count, 2
    assert g.friendships.include?(Friendship.find_by_id(friendships(:ryan_user1).id))
  end

  def test_members_collection
    r = User.find_by_id(users(:ryan).id)
    assert_not_nil r
    u1 = User.find_by_id(users(:user1).id)
    assert_not_nil u1
    assert r.groups.find_by_id(groups(:ryan_family).id).members.include?(u1)
  end

  def test_group_name_set
    g = Group.create(:user_id => users(:user3).id, :name => "This is a test Group.")
    assert_not_nil g.id
    assert_equal g.group_name, "this_is_a_test_group_"
  end

  def test_required_attributes
    g = Group.create(:name => "This is a test Group.")
    assert_nil g.id
    assert_not_nil g.errors.on(:user_id)
    assert_nil g.errors.on(:group_name)
  end

  def test_unique_groups_for_users
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    g2 = Group.create(:user_id => users(:ryan).id, :name => groups(:ryan_family).group_name)
    assert_nil g2.id
    assert_not_nil g2.errors.on(:group_name)
    g2 = Group.create(:user_id => users(:user3).id, :name => groups(:ryan_family).group_name)
    assert_not_nil g2.id
    assert_nil g2.errors.on(:group_name)
  end

  def test_add_member
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    u3 = User.find_by_id(users(:user3).id)
    assert !g.members.include?(u3)
    assert !g.user.friends.include?(u3)
    num = g.members.count
    g.add_member(u3)
    assert_equal num + 1, g.members.count
  end

  def test_add_member_already_exists
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    u2 = User.find_by_id(users(:user2).id)
    assert g.members.include?(u2)
    num = g.members.count
    g.add_member(u2)
    assert_equal num, g.members.count
  end

  def test_add_member_does_not_exist_but_friendship_does
    g = Group.find_by_id(groups(:user1_family).id)
    assert_not_nil g
    u2 = User.find_by_id(users(:user2).id)
    assert !g.members.include?(u2)
    assert g.user.friends.include?(u2)
    num = g.members.count
    g.add_member(u2)
    assert_equal num + 1, g.members.count
  end

  def test_remove_member
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    g2 = Group.find_by_id(groups(:ryan_friends).id)
    assert_not_nil g2
    u1 = User.find_by_id(users(:user1).id)
    assert g.members.include?(u1)
    assert g.user.friends.include?(u1)
    assert g2.members.include?(u1)
    assert g2.user.friends.include?(u1)
    num = g.members.count
    num2 = g2.members.count
    g.remove_member(u1)
    assert_equal num - 1, g.members.count
    assert_equal num - 1, g.group_memberships.count
    assert_equal num - 1, g.friendships.count
    assert_equal num2, g2.members.count
    assert_equal num2, g2.group_memberships.count
    assert_equal num2, g2.friendships.count
    # Should not remove the friendship.
    assert g.user.friends.include?(u1)
    assert g2.user.friends.include?(u1)
  end

  def test_remove_member_does_not_exist_but_friendship_does
    g = Group.find_by_id(groups(:user1_family).id)
    assert_not_nil g
    u2 = User.find_by_id(users(:user2).id)
    assert !g.members.include?(u2)
    assert g.user.friends.include?(u2)
    num = g.members.count
    g.remove_member(u2)
    assert_equal num, g.members.count
    assert_equal num, g.group_memberships.count
    assert_equal num, g.friendships.count
    assert g.user.friends.include?(u2)
  end

  def test_remove_member_and_friendship_do_not_exist
    g = Group.find_by_id(groups(:user1_family).id)
    assert_not_nil g
    u4 = User.find_by_id(users(:user4).id)
    assert !g.members.include?(u4)
    assert !g.user.friends.include?(u4)
    num = g.members.count
    g.remove_member(u4)
    assert_equal num, g.members.count
    assert_equal num, g.group_memberships.count
    assert_equal num, g.friendships.count
    assert !g.user.friends.include?(u4)
  end

  def test_destroy_dependents_group_memberships
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    num = GroupMembership.find_all_by_group_id(groups(:ryan_family).id).count
    assert_not_equal 0, num
    assert_equal num, g.group_memberships.count
    g.destroy
    assert_equal 0, GroupMembership.find_all_by_group_id(groups(:ryan_family).id).count
  end

  def test_find_by_group_name_and_username
    assert_equal Group.find_by_id(groups(:ryan_family).id), Group.find_by_group_name_and_username(groups(:ryan_family).group_name, users(:ryan).username)
    assert_nil Group.find_by_group_name_and_username(groups(:ryan_family).group_name, users(:user3).username)
  end

end
