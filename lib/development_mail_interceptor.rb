class DevelopmentMailInterceptor
  def self.delivering_email(mail)
    mail.subject = "#{mail.to} || #{mail.subject}"
    mail.to = Const::get(:test_email_recipient)
  end
end
