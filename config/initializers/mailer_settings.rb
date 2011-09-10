require 'development_mail_interceptor'
require 'mail_observer'

ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true,
	:domain => 'statigories.com',
  :user_name => 'noreply@statigories.com',
  :password => 'N0-r3P1y'
}

ActionMailer::Base.default_url_options[:host] = 'statigories.com'
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development? or Rails.env.test?
ActionMailer::Base.register_observer(MailObserver)
