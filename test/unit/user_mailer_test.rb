require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def test_email_sent
    # Make sure the email is "sent"; it must be on the list of test emails
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_username(users(:ryan).username)
    assert u
    unless Constant::get(:test_emails)[0] == '': u.email = Constant::get(:test_emails)[0] end
    log_count = EventLog.find(:all).count
    assert UserMailer.deliver_email_verification(u)
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    # Make sure an event was written
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::EMAIL_MSG_SENT
    assert_equal EventLog.find(:last).user_id, u.id
  end

  def test_email_not_sent_not_test_address
    # Make sure the email is not "sent"; because it is not on the list of test emails
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_username(users(:ryan).username)
    assert u
    unless Constant::get(:test_emails)[0] == '': u.email = Constant::get(:test_emails)[0] end
    # Fake using an email not on the list
    u.email = 'xx' + u.email
    log_count = EventLog.find(:all).count
    assert !UserMailer.deliver_email_verification(u)
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
    assert_equal log_count, EventLog.find(:all).count
  end
end
