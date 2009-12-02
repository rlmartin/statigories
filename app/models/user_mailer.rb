class UserMailer < ActionMailer::Base
  def email_verification(recipient)
    @subject = I18n.t(:subject_email_verification)
    body[:recipient] = recipient
    @recipients = recipient[:first_name] + ' ' + recipient[:last_name] + ' <' + recipient[:email] + '>'
    @from = 'MyLogs <noreply@mylo.gs>'
		@content_type = 'text/html'
		@sent_on = Time.now
  end

  def password_reset(recipient)
    @subject = I18n.t(:subject_password_reset)
    body[:recipient] = recipient
    @recipients = recipient[:first_name] + ' ' + recipient[:last_name] + ' <' + recipient[:email] + '>'
    @from = 'MyLogs <noreply@mylo.gs>'
		@content_type = 'text/html'
		@sent_on = Time.now
  end
end
