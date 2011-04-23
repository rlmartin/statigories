class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => 'User'
  has_many :group_memberships, :dependent => :destroy
  validates_presence_of [:user_id, :friend_id]
  validates_uniqueness_of :friend_id, :scope => :user_id
  after_create :after_create_cleanup_inverse

  def block
    update_attributes(:responded => true, :blocked => true)
  end

  def ignore
    update_attributes(:responded => true)
  end

  protected
  def after_create_cleanup_inverse
    inverse = Friendship.find_by_friend_id_and_user_id(self.user_id, self.friend_id)
    unless inverse == nil
      inverse.update_attributes(:responded => true, :blocked => false)
      update_attributes(:responded => true, :blocked => false)
    end
  end
end
