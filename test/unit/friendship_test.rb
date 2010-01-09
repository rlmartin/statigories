require 'test_helper'

class FriendshipTest < ActiveSupport::TestCase

  def test_friendship_connection
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
    assert_equal u.inverse_friends.count, 2
    assert_equal u.inverse_friendships.count, 2
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    assert_equal u2.friends.count, 1
    assert_equal u2.friendships.count, 1
    assert_equal u2.inverse_friends.count, 2
    assert_equal u2.inverse_friendships.count, 2
    # Failures on the association can only be caught successfully when adding the association (the :through, not the :has_many).
    f = u.friendships.build(:friend => u2)
    assert !f.save
    assert f.errors.on(:friend_id)
    assert_equal u.friends.count, 2
    assert_equal u.inverse_friends.count, 2
    assert_equal u2.friends.count, 1
    assert_equal u2.inverse_friends.count, 2
    u2.friends << u
    assert_equal u.friends.count, 2
    assert_equal u.inverse_friends.count, 3
    assert_equal u2.friends.count, 2
    assert_equal u2.inverse_friends.count, 2
  end

  def test_inverse_friendship_cleanup
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    assert u.friends.include?(u2)
    assert !u2.friends.include?(u)
    friendship = u.friendships.find_by_friend_id(u2.id)
    assert !friendship.responded
    u2.friends << u
    assert u2.friends.include?(u)
    friendship = u.friendships.find_by_friend_id(u2.id)
    assert friendship.responded
    assert !friendship.blocked
    friendship = u2.friendships.find_by_friend_id(u.id)
    assert friendship.responded
    assert !friendship.blocked
    u3 = User.find_by_id(users(:user3).id)
    assert_not_nil u3
    assert !u2.friends.include?(u3)
    assert !u3.friends.include?(u2)
    u2.friends << u3
    friendship = u2.friendships.find_by_friend_id(u3.id)
    assert !friendship.responded
    assert !friendship.blocked
  end

  def test_block
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friendship = u2.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil friendship
    assert !friendship.blocked
    friendship.block
    assert friendship.blocked
    assert friendship.responded
  end

  def test_ignore
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    friendship = u2.inverse_friendships.find_by_user_id(users(:ryan).id)
    assert_not_nil friendship
    assert !friendship.responded
    friendship.ignore
    assert friendship.responded
  end
end
