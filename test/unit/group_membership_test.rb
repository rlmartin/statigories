require 'test_helper'

class GroupFriendTest < ActiveSupport::TestCase
  def test_associations
    gm = GroupMembership.find_by_id(group_memberships(:ryan_family_user1).id)
    assert_not_nil gm
    f = Friendship.find_by_id(friendships(:ryan_user1).id)
    assert_not_nil f
    assert_equal gm.friendship, f
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    assert_equal gm.group, g
    u1 = User.find_by_id(users(:user1).id)
    assert_not_nil u1
    assert_equal gm.friend, u1
  end

  def test_required_attributes
    gm = GroupMembership.create(:group_id => groups(:ryan_family).id)
    assert_nil gm.id
    assert !gm.errors[:friendship_id].empty?
    assert gm.errors[:group_id].empty?
    gm = GroupMembership.create(:friendship_id => friendships(:ryan_user1).id)
    assert_nil gm.id
    assert gm.errors[:friendship_id].empty?
    assert !gm.errors[:group_id].empty?
  end

  def test_uniqueness
    gm = GroupMembership.find_by_id(group_memberships(:ryan_family_user1).id)
    assert_not_nil gm
    f = Friendship.find_by_id(friendships(:ryan_user1).id)
    assert_not_nil f
    assert_equal gm.friendship, f
    g = Group.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    assert_equal gm.group, g
    gm = GroupMembership.create(:friendship_id => f.id, :group_id => g.id)
    assert_nil gm.id
    assert !gm.errors[:friendship_id].empty?
  end

  def test_friendship_matches_group_owner
    assert_nil GroupMembership.find_by_friendship_id_and_group_id(friendships(:user1_user3).id, groups(:user1_family).id)
    gm = GroupMembership.create(:friendship_id => friendships(:user1_user3).id, :group_id => groups(:user1_family).id)
    assert_not_nil gm.id
    assert_nil GroupMembership.find_by_friendship_id_and_group_id(friendships(:user3_user1).id, groups(:user1_family).id)
    gm = GroupMembership.create(:friendship_id => friendships(:user3_user1).id, :group_id => groups(:user1_family).id)
    assert_nil gm.id
    assert !gm.errors[:friendship_id].empty?
    assert gm.errors[:friendship_id].include?(I18n.t(:error_group_membership_group_does_not_match_friendship))
  end

  def test_inverse_group_memberships
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    assert_equal u.inverse_group_memberships.count, 0
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_equal u.inverse_group_memberships.count, 2
    assert u.inverse_group_memberships.include?(GroupMembership.find_by_id(group_memberships(:ryan_family_user1).id))
    assert u.inverse_group_memberships.include?(GroupMembership.find_by_id(group_memberships(:ryan_friends_user1).id))
  end

  def test_add_existing_friend_to_group
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user4).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    assert !u.groups[0].members.include?(u2)
    gm = u.add_friend_to_group(u2, u.groups[0])
    assert_not_nil gm
    assert_not_nil gm.id
    assert_equal count + 1, u.groups[0].group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_add_new_friend_to_group
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user5).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert !u.friends.include?(u2)
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    assert !u.groups[0].members.include?(u2)
    gm = u.add_friend_to_group(u2, u.groups[0])
    assert_not_nil gm
    assert_not_nil gm.id
    assert_equal count + 1, u.groups[0].group_memberships.count
    assert_equal friend_count + 1, u.friends.count
  end

  def test_do_not_add_existing_friend_to_missing_group
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user4).id)
    assert_not_nil u2
    u3 = User.find_by_id(users(:ryan).id)
    assert_not_nil u3
    assert !u.groups.include?(u3.groups[0])
    count = u3.groups[0].group_memberships.count
    assert !u3.groups[0].members.include?(u2)
    gm = u.add_friend_to_group(u2, u3.groups[0])
    assert_nil gm
    assert_equal count, u3.groups[0].group_memberships.count
  end

  def test_do_not_add_new_friend_to_null_group
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user5).id)
    assert_not_nil u2
    assert !u.friends.include?(u2)
    count = u.friends.count
    gm = u.add_friend_to_group(u2, nil)
    assert_nil gm
    assert_equal count, u.friends.count
  end

  def test_do_not_add_null_friend_to_group
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    friend_count = u.friends.count
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    gm = u.add_friend_to_group(nil, u.groups[0])
    assert_nil gm
    assert_equal count, u.groups[0].group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_add_existing_member_to_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    count = g.group_memberships.count
    assert g.members.include?(u2)
    gm = u.add_friend_to_group(u2, g)
    assert_not_nil gm
    assert_not_nil gm.id
    assert_equal count, g.group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_add_self_to_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    friend_count = u.friends.count
    assert !u.friends.include?(u)
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    assert !u.groups[0].members.include?(u)
    gm = u.add_friend_to_group(u, u.groups[0])
    assert_nil gm
    assert_equal count, u.groups[0].group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_add_new_friend_to_not_my_group
    u = User.find_by_id(users(:user2).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user5).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert !u.friends.include?(u2)
    group = Group.find_by_id(groups(:ryan_friends).id)
    assert_not_nil group
    count = group.group_memberships.count
    assert !group.members.include?(u2)
    gm = u.add_friend_to_group(u2, group)
    assert_nil gm
    assert_equal count, group.group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_remove_friend_from_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    g = u.groups.find_by_group_name(groups(:ryan_family).group_name)
    assert_not_nil g
    count = g.group_memberships.count
    assert g.members.include?(u2)
    gm = u.remove_friend_from_group(u2, g)
    assert_not_nil gm
    assert_not_nil gm.id
    assert_equal count - 1, g.group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_remove_nonmember_from_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    group = u.groups.find_by_id(groups(:ryan_friends).id)
    assert_not_nil group
    count = group.group_memberships.count
    assert !group.members.include?(u2)
    gm = u.remove_friend_from_group(u2, group)
    assert_nil gm
    assert_equal count, group.group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_remove_nonfriend_from_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user4).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert !u.friends.include?(u2)
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    assert !u.groups[0].members.include?(u2)
    gm = u.remove_friend_from_group(u2, u.groups[0])
    assert_nil gm
    assert_equal count, u.groups[0].group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_remove_null_friend_from_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    friend_count = u.friends.count
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    gm = u.remove_friend_from_group(nil, u.groups[0])
    assert_nil gm
    assert_equal count, u.groups[0].group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_remove_friend_from_null_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    gm = u.remove_friend_from_group(u2, nil)
    assert_nil gm
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_remove_friend_from_not_my_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    group = Group.find_by_id(groups(:user1_family))
    assert_not_nil group
    count = group.group_memberships.count
    assert !group.members.include?(u2)
    gm = u.remove_friend_from_group(u2, group)
    assert_nil gm
    assert_equal count, group.group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_do_not_remove_member_from_not_my_group
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friend_count = u.friends.count
    assert u.friends.include?(u2)
    group = Group.find_by_id(groups(:ryan_family))
    assert_not_nil group
    count = group.group_memberships.count
    assert group.members.include?(u2)
    gm = u.remove_friend_from_group(u2, group)
    assert_nil gm
    assert_equal count, group.group_memberships.count
    assert_equal friend_count, u.friends.count
  end

  def test_remove_self_from_group
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u
    friend_count = u.friends.count
    assert !u.friends.include?(u)
    assert_not_nil u.groups[0]
    count = u.groups[0].group_memberships.count
    assert !u.groups[0].members.include?(u)
    gm = u.remove_friend_from_group(u, u.groups[0])
    assert_nil gm
    assert_equal count, u.groups[0].group_memberships.count
    assert_equal friend_count, u.friends.count
  end

end

