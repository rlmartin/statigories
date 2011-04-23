class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :friendship
  delegate :friend, :to => :friendship
  validates_presence_of [:group_id, :friendship_id]
  validates_uniqueness_of :friendship_id, :scope => :group_id
  before_validation :before_validation_check_friendship

  protected
  def before_validation_check_friendship
    group = Group.find_by_id(self.group_id)
    unless group == nil or self.friendship_id == nil
      unless group.user.friendships.include?(Friendship.find_by_id(self.friendship_id))
        errors.add(:friendship_id, I18n.t(:error_group_membership_group_does_not_match_friendship))
        false
      end
    end
  end
end
