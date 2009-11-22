class User < ActiveRecord::Base
	validates_presence_of :email, :username, :first_name, :last_name, :password
	validates_uniqueness_of :email
	validates_uniqueness_of :username
	validates_format_of :username, :with => /^\w+$/
	validates_confirmation_of :password
  before_validation :_trim_values
	before_validation :hash_pwd
	before_validation :streamline_username
	before_validation :set_verification_code
	xss_terminate :except => [:password]
	validates_email_veracity_of :email
	after_save :send_verification_email

	private
	def hash_pwd
		# Only save hashes of the password, not the password itself.
		self.password = Digest::MD5.hexdigest(self.password)
	end

	def streamline_username
		# Make all usernames lowercase.
		self.password.downcase!
	end

	def set_verification_code
		# For new users, set the authorization code so they can authorize their email address.
		unless self.verified or self.verification_code != "": self.verification_code = Digest::MD5.hexdigest(self.email + Time.now.to_f.to_s) end
	end

	def send_verification_email
		unless self.verification_code == "": UserMailer.deliver_email_verification(self) end
	end
end
