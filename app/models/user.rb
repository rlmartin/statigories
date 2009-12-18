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
  before_validation :_trim_values
	after_validation :hash_pwd
	before_validation :streamline_username
	before_validation :set_verification_code
	xss_terminate :except => [:password]
	validates_email_veracity_of :email
	after_save :send_verification_email
  has_many :event_logs

	def to_param
    "#{self.username}" 
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

	def send_password_email
    if self.password_recovery_code == '' or self.password_recovery_code == nil
      self.password_recovery_code = StringLib.MD5(self.email + Time.now.to_f.to_s)
      self.password_recovery_code_set = Time.now
      self.save
    end
		UserMailer.deliver_password_reset(self)
	end

	def send_verification_email(force = false)
		if self.verification_code != "" and (self.verification_code_changed? or force)
      UserMailer.deliver_email_verification(self)
    else
      false
    end
	end

	def set_verification_code
		# For new users or users who change their email address, set the authorization code so they can authorize their email address.
    if self.email_changed?: self.verified = false end
		unless self.verified or self.verification_code != "": self.verification_code = StringLib.MD5((self.email || '') + Time.now.to_f.to_s) end
	end

	private
	def hash_pwd
		# Only save hashes of the password, not the password itself.
    if self.password_changed?
		  unless self.password == nil: self.password = StringLib.MD5(self.password) end
		  unless self.password_confirmation == nil: self.password_confirmation = StringLib.MD5(self.password_confirmation) end
    end
	end

	def streamline_username
		# Make all usernames lowercase.
		unless self.username == nil: self.username.downcase! end
	end
end
