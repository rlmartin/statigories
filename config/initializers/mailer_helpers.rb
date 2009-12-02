module ActionMailer
  class Base
		before_deliver :check_allowed_emails

		protected
		def check_allowed_emails(mail)
			# Check the constant to see if the email should be sent.
			@allowed = Constant::get(:test_emails)
			unless @allowed.count == 0 or (@allowed.count == 1 and @allowed[0] == '')
				@list = mail.to
				# Clean up the two lists.
				@list.compact!
				@list.each_index { |i| @list[i].downcase!; @list[i].strip! }
				# If every email on the recipient list is allowed, send the email.
				unless (@allowed & @list).count == @list.count
					self.class.halt_callback_chain
				end
			end
		end
  end
end
