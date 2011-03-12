class UserMailer < ActionMailer::Base
  default :from => I18n.t(:no_reply_from_name) + ' <' + I18n.t(:no_reply_email) + '>'

  def email_verification(recipient)
    prep_mailing(recipient, recipient.first_name + ' ' + recipient.last_name + ' <' + recipient.email + '>', I18n.t(:subject_email_verification))
  end

  def new_friend_request(recipient, friend = nil)
    @friend = friend
    prep_mailing(recipient, recipient.first_name + ' ' + recipient.last_name + ' <' + recipient.email + '>', I18n.t(:subject_new_friend_request))
  end

  def password_reset(recipient)
    prep_mailing(recipient, recipient.first_name + ' ' + recipient.last_name + ' <' + recipient.email + '>', I18n.t(:subject_password_reset))
  end

protected
  def prep_mailing(recipient = nil, to = '', subject = '')
    # A little bit of a hack, but this method should be called by all mailers with User as a recipient
    @recipient = recipient
    email = mail(:to => to, :subject => subject)
    # Set the recipient instance variable for use in the interceptors & observers.
    email.instance_variable_set(:@recipient, recipient)
    email
  end
end
