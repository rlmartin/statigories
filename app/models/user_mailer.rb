class UserMailer < ActionMailer::Base
  def email_verification(recipient)
    prep_mailing(recipient)
    @subject = I18n.t(:subject_email_verification)
    body[:recipient] = recipient
    @recipients = recipient[:first_name] + ' ' + recipient[:last_name] + ' <' + recipient[:email] + '>'
    @from = 'MyLogs <noreply@mylo.gs>'
		@content_type = 'text/html'
		@sent_on = Time.now
  end

  def password_reset(recipient)
    prep_mailing(recipient)
    @subject = I18n.t(:subject_password_reset)
    body[:recipient] = recipient
    @recipients = recipient[:first_name] + ' ' + recipient[:last_name] + ' <' + recipient[:email] + '>'
    @from = 'MyLogs <noreply@mylo.gs>'
		@content_type = 'text/html'
		@sent_on = Time.now
  end

protected
  def prep_mailing(recipient)
    # A little bit of a hack, but this method should be called by all mailers with User as a recipient
    @recipient = recipient
  end
end
