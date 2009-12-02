class User < ActiveRecord::Base
	validates_presence_of :email, :username, :first_name, :last_name, :password
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
	after_create :send_verification_email

	def to_param
    "#{self.username}" 
  end

	def send_password_email
    if self.password_recovery_code == '' or self.password_recovery_code == nil
      self.password_recovery_code = Digest::MD5.hexdigest(self.email + Time.now.to_f.to_s)
      self.password_recovery_code_set = Time.now
      self.save
    end
		UserMailer.deliver_password_reset(self)
	end

	def send_verification_email
		if self.verification_code == ""
      false
    else
      UserMailer.deliver_email_verification(self)
    end
	end

	def set_verification_code
		# For new users, set the authorization code so they can authorize their email address.
		unless self.verified or self.verification_code != "": self.verification_code = Digest::MD5.hexdigest(self.email + Time.now.to_f.to_s) end
	end

	private
	def hash_pwd
		# Only save hashes of the password, not the password itself.
		unless self.password == nil: self.password = Digest::MD5.hexdigest(self.password) end
	end

	def streamline_username
		# Make all usernames lowercase.
		unless self.password == nil: self.password.downcase! end
	end
end
