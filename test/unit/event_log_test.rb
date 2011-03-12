require 'test_helper'

class EventLogTest < ActiveSupport::TestCase

  def test_save_force_user_agent_and_ip_address
    e = EventLog.create(:event_id => Event::LOGIN, :user_id => users(:ryan).id, :user_agent_id => user_agents(:one).id, :ip_address => ActionController::TestRequest.new.remote_ip + 'x')
    assert_not_nil e
    assert_not_nil e.id
    assert_equal e.ip_address, ActionController::TestRequest.new.remote_ip + 'x'
    assert_equal e.user_agent_id, user_agents(:one).id
    assert_equal e.errors.count, 0
  end

  def test_save_with_default_request
    e = EventLog.create(:event_id => Event::LOGIN, :user_id => users(:ryan).id)
    assert_not_nil e
    assert_not_nil e.id
    assert e.errors[:user_agent_id].empty?
    assert_equal e.ip_address, ActionController::TestRequest.new.remote_ip
    assert_equal e.user_agent_id, UserAgent.find_by_user_agent(ActionController::TestRequest.new.user_agent).id
    assert_equal e.errors.count, 0
  end

  def test_does_not_save_missing_event_id
    e = EventLog.create(:user_id => users(:ryan).id)
    assert_nil e.id
    assert !e.errors[:event_id].empty?
    assert_equal e.errors.count, 1
  end

  def test_create_with_small_data
    extras_count = EventLogExtra.find(:all).count
    e = EventLog.create(:event_id => Event::LOGIN, :user_id => users(:ryan).id, :event_data => 'data')
    assert_not_nil e.id
    assert_equal e.event_log_extras.count, 0
    assert_equal extras_count, EventLogExtra.find(:all).count
  end

  def test_create_with_long_data
    e = EventLog.create(:event_id => Event::LOGIN, :user_id => users(:ryan).id, :event_data => '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890')
    assert_not_nil e.id
    assert_equal e.event_data, ''
    assert_equal e.event_log_extras.count, 1
    assert_equal e.event_log_extras[0].id, EventLogExtra.find(:last).id
  end

end
