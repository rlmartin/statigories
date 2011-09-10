require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def test_email_sent
    # Make sure the email is "sent"; it must be on the list of test emails
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_username(users(:ryan).username)
    assert u
    u_email = u.email
    log_count = EventLog.find(:all).count
    assert UserMailer.email_verification(u).deliver
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    # Make sure the email is only sent to the test recipient, not the actual email.
    assert_not_equal u_email, Const::get(:test_email_recipient)
    assert_not_equal u_email, ActionMailer::Base.deliveries[num_deliveries].to[0]
    assert_equal Const::get(:test_email_recipient), ActionMailer::Base.deliveries[num_deliveries].to[0]
    # Make sure an event was written
    assert_equal log_count + 1, EventLog.find(:all).count
    assert_equal EventLog.find(:last).event_id, Event::EMAIL_MSG_SENT
    assert_equal EventLog.find(:last).user_id, u.id
  end
end
