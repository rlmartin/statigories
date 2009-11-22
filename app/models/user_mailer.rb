class UserMailer < ActionMailer::Base
  def email_verification(recipient)
    @subject = 'Please verify your email address'
    body[:recipient] = recipient
    @recipients = recipient[:first_name] + ' ' + recipient[:last_name] + ' <' + recipient[:email] + '>'
    @from = 'MyLogs <noreply@mylo.gs>'
		@content_type = 'text/html'
		@sent_on = Time.now
  end
end
