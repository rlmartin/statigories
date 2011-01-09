class Group < ActiveRecord::Base
  belongs_to :user
  has_many :group_memberships, :dependent => :destroy
  has_many :friendships, :through => :group_memberships
  validates_presence_of [:user_id, :group_name]
  validates_uniqueness_of :group_name, :scope => :user_id
  before_validation :before_validation_generate_group_name

  def add_member(user)
    if self.members.include?(user)
      self.friendships
    else
      self.user.add_friend(user)
      self.friendships << self.user.friendships.find_by_friend_id(user.id)
    end
  end

  def self.find_by_group_name_and_username(group_name, username)
    find(:first, :joins => 'JOIN users ON users.id = groups.user_id', :conditions => [ 'group_name=? AND users.username=?', group_name, username ])
  end

  def members
    self.friendships.collect(&:friend).uniq
  end

  def remove_member(user)
    gm = self.group_memberships.find_by_friendship_id(self.user.friendships.find_by_friend_id(user.id))
    unless gm == nil
      gm.destroy
      self.reload
    end
  end

  protected
  def before_validation_generate_group_name
    self.group_name = self.name.gsub(/\W/, '_').downcase
  end
end
