class User < ActiveRecord::Base
  include StringLib
	validates_presence_of :email, :username, :first_name, :last_name, :password
	validates_presence_of :email_confirmation, :if => :email_changed?
	validates_presence_of :password_confirmation, :if => :password_changed?
	validates_format_of :username, :with => /\A(\w+)\Z/
	validates_uniqueness_of :email
	validates_uniqueness_of :username
	validates_confirmation_of :password
	validates_confirmation_of :email
	xss_terminate :except => [:password]
  before_validation :_trim_values
	after_validation :hash_pwd
	before_validation :streamline_username
	before_validation :set_verification_code
	validates_email_veracity_of :email
	after_save :send_verification_email
  has_many :event_logs
  has_many :friendships
  has_many :friends, :through => :friendships, :uniq => true
  has_many :groups, :dependent => :destroy
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => :friend_id
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user, :uniq => true
  has_many :client_applications
  has_many :tokens, :class_name=>"OauthToken",:order=>"authorized_at desc",:include=>[:client_application]
  has_many :log_entries, :dependent => :destroy

	def to_param
    "#{self.username}" 
  end

  def add_friend(friend)
    unless self.friends.include?(friend)
      self.friends << friend
      friend.send_new_friend_request_email(self)
    end
  end

  def add_friend_to_group(friend, group)
    unless friend == nil or group == nil
      if (friend.id != self.id) and groups.include?(group)
        add_friend(friend)
        friendship = friendships.find_by_friend_id(friend.id)
        gm = group.group_memberships.find_by_friendship_id(friendship.id)
        if gm == nil
          group.group_memberships.create(:friendship_id => friendship.id)
        else
          gm
        end
      end
    end
  end

  def add_event(event_id, event_data = '')
    self.event_logs.create(:event_id => event_id, :event_data => event_data)
  end

  def add_deleted_event(data = '')
    self.add_event(Event::USER_DELETED, data)
  end

  def add_edited_event(data = '')
    self.add_event(Event::USER_EDITED, data)
  end

  def add_login_event(data = '')
    self.add_event(Event::LOGIN, data)
  end

  def add_logout_event(data = '')
    self.add_event(Event::LOGOUT, data)
  end

  def add_msg_sent_event(data = '')
    self.add_event(Event::EMAIL_MSG_SENT, data)
  end

  def non_blocked_friends
    friends.where('friendships.blocked = 0').includes(:friendships)
  end

  def full_name
    first_name + ' ' + last_name
  end

  # Groups this user is a member of
  def inverse_group_memberships
    a = []
    self.inverse_friendships.each do |f|
      a = a | f.group_memberships
    end
    a.uniq
  end

  def remove_friend(friend)
    if friend == nil
      false
    else
      friendship = friendships.find_by_friend_id(friend.id)
      if friendship == nil
        false
      else
        friendship.destroy
        true
      end
    end
  end

  def remove_friend_from_group(friend, group)
    unless friend == nil or group == nil
      if (friend.id != self.id) and groups.include?(group)
        friendship = friendships.find_by_friend_id(friend.id)
        unless friendship == nil
          gm = group.group_memberships.find_by_friendship_id(friendship.id)
          gm.destroy unless gm == nil
          gm
        end
      end
    end
  end

	def send_new_friend_request_email(friend = nil)
		if Const::get(:send_level_two_emails)
      UserMailer.new_friend_request(self, friend).deliver
    else
      true
    end
	end

	def send_password_email
    if self.password_recovery_code == '' or self.password_recovery_code == nil
      self.password_recovery_code = StringLib.MD5(self.email + Time.now.to_f.to_s)
      self.password_recovery_code_set = Time.now
      self.save
    end
		UserMailer.password_reset(self).deliver
	end

	def send_verification_email(force = false)
		if self.verification_code != "" and (self.verification_code_changed? or force)
      UserMailer.email_verification(self).deliver
    else
      false
    end
	end

	def set_verification_code
		# For new users or users who change their email address, set the authorization code so they can authorize their email address.
    self.verified = false if self.email_changed?
		self.verification_code = StringLib.MD5((self.email || '') + Time.now.to_f.to_s) unless self.verified or self.verification_code != ""
	end

  def unanswered_friend_requests
    inverse_friends.where('friendships.responded = 0 AND friendships.blocked = 0').includes(:friendships)
  end

	private
	def hash_pwd
		# Only save hashes of the password, not the password itself.
    if self.password_changed?
		  self.password = StringLib.MD5(self.password) unless self.password == nil
		  self.password_confirmation = StringLib.MD5(self.password_confirmation) unless self.password_confirmation == nil
    end
	end

	def streamline_username
		# Make all usernames lowercase.
		self.username.downcase! unless self.username == nil
	end
end
