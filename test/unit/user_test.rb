require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_full_name
    u = User.find_by_id(users(:ryan).id)
    assert_equal u.full_name, u.first_name + ' ' + u.last_name
  end

  def test_should_not_be_vaild_without_email
    u = User.create(:username => "john", :password => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:email)
  end

  def test_should_not_be_vaild_without_username
    u = User.create(:email => "johndoe@gmail.com", :password => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:username)
  end

  def test_should_not_be_vaild_without_password
    u = User.create(:email => "johndoe@gmail.com", :username => "john", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:password)
  end

  def test_should_not_be_vaild_without_first_name
    u = User.create(:email => "johndoe@gmail.com", :username => "john", :password => "pwd", :last_name => "Doe")
    assert u.errors.on(:first_name)
  end

  def test_should_not_be_vaild_without_last_name
    u = User.create(:email => "johndoe@gmail.com", :username => "john", :password => "pwd", :first_name => "John")
    assert u.errors.on(:last_name)
  end

  def test_invalid_email_format
    u = User.create(:email => "johndoe", :username => "john", :password => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:email)
  end

  def test_invalid_email_format_at
    u = User.create(:email => "johndoe@", :username => "john", :password => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:email)
  end

  def test_missing_email_confirmation
    u = User.create(:email => "johndoe@gmail.com", :username => "john", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:email_confirmation)
  end

  def test_incorrect_email_confirmation
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe1@gmail.com", :username => "john", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:email)
  end

  def test_missing_password_confirmation
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "john", :password => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:password_confirmation)
  end

  def test_incorrect_password_confirmation
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "john", :password => "pwd", :password_confirmation => "pwd1", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:password)
  end

  def test_invalid_username_space
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "jo hn", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:username)
  end

  def test_invalid_username_exclamation
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "jo!hn", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:username)
  end

  def test_invalid_username_dash
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "jo-hn", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:username)
  end

  def test_email_already_exists
    u = User.create(:email => users(:ryan).email, :email_confirmation => users(:ryan).email, :username => "john", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:email)
  end

  def test_username_already_exists
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => users(:ryan).username, :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.errors.on(:username)
  end

  def test_successful_update_without_email_or_password
    u = User.find_by_username(users(:ryan).username)
    # Store the current values.
    id = u.id
    email = u.email
    first_name = u.first_name
    last_name = u.last_name
    pwd = u.password
    username = u.username
    u.update_attributes(:username => "john", :first_name => "John", :last_name => "Doe")
    # Successful save
    assert u.save
    u = User.find_by_id(id)
    # Make sure the email & password do not change.
    assert_equal email, u.email
    assert_equal pwd, u.password
    # Make sure the other values were updated.
    assert_not_equal first_name, u.first_name
    assert_equal u.first_name, "John"
    assert_not_equal last_name, u.last_name
    assert_equal u.last_name, "Doe"
    assert_not_equal username, u.username
    assert_equal u.username, "john"
  end

  def test_successful_update_email_and_password
    u = User.find_by_username(users(:ryan).username)
    # Store the current values.
    id = u.id
    email = u.email
    first_name = u.first_name
    last_name = u.last_name
    pwd = u.password
    username = u.username
    u.update_attributes(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :password => "newpwd", :password_confirmation => "newpwd")
    # Successful save
    assert u.save
    u = User.find_by_id(id)
    # Make sure the other values do not change.
    assert_equal first_name, u.first_name
    assert_equal last_name, u.last_name
    assert_equal username, u.username
    # Make sure the email & password were updated.
    assert_not_equal email, u.email
    assert_equal u.email, "johndoe@gmail.com"
    assert_not_equal pwd, u.password
    assert_equal u.password, Digest::MD5.hexdigest("newpwd")
  end

  def test_unsuccessful_update_without_email_confirmation
    u = User.find_by_username(users(:ryan).username)
    u.update_attributes(:email => "johndoe@gmail.com")
    assert u.errors.on(:email_confirmation)
  end

  def test_unsuccessful_update_invalid_email_confirmation
    u = User.find_by_username(users(:ryan).username)
    u.update_attributes(:email => "johndoe@gmail.com", :email_confirmation => "johndoe1@gmail.com")
    assert u.errors.on(:email)
  end

  def test_unsuccessful_update_without_password_confirmation
    u = User.find_by_username(users(:ryan).username)
    u.update_attributes(:password => "newpwd")
    assert u.errors.on(:password_confirmation)
  end

  def test_unsuccessful_update_invalid_password_confirmation
    u = User.find_by_username(users(:ryan).username)
    u.update_attributes(:password => "newpwd", :password_confirmation => "newpwd1")
    assert u.errors.on(:password)
  end

  def test_invalid_email_server
    u = User.create(:email => "johndoe@xaxgmailxax.com", :email_confirmation => "johndoe@xaxgmailxax.com", :username => "john", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert !u.valid?
    assert u.errors.on(:email)
  end

  def test_attributes_trimmed
    u = User.create(:email => "  johndoe@gmail.com  ", :email_confirmation => "johndoe@gmail.com", :username => "  john  ", :password => "  pwd  ", :password_confirmation => "pwd", :first_name => "  John  ", :last_name => "  Doe  ")
    assert u.valid?
    assert_not_equal u.id, nil
    assert_equal u.email, 'johndoe@gmail.com'
    assert_equal u.username, 'john'
    assert_equal u.password, Digest::MD5.hexdigest("pwd")
    assert_equal u.first_name, 'John'
    assert_equal u.last_name, 'Doe'
  end

  def test_attributes_no_xss
    u = User.create(:email => "johndoe@gmail.com<script></script>", :email_confirmation => "johndoe@gmail.com", :username => "john  <b>", :password => "<i>pwd</i>", :password_confirmation => "<i>pwd</i>", :first_name => "John<br />", :last_name => "<em>Doe</em>")
    assert u.valid?
    assert_not_equal u.id, nil
    assert_equal u.email, 'johndoe@gmail.com'
    assert_equal u.username, 'john'
    assert_equal u.password, Digest::MD5.hexdigest("<i>pwd</i>")
    assert_equal u.first_name, 'John'
    assert_equal u.last_name, 'Doe'
  end

  def test_username_is_lowercase
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "JOHN", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert_equal u.username, 'john'
    assert_not_equal u.username, 'JOHN'
  end

  def test_verification_set
    u = User.create(:email => "johndoe@gmail.com", :email_confirmation => "johndoe@gmail.com", :username => "JOHN", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.verification_code != nil
    assert !u.verified
  end

  def test_user_created
    num_deliveries = ActionMailer::Base.deliveries.size
    # Change an existing user, so this can test using a valid "test" email address.
    u = User.find_by_email(users(:ryan).email)
    unless u == nil: u.update_attributes(:email => "xx" + users(:ryan).email, :email_confirmation => "xx" + users(:ryan).email) end
    u = User.create(:email => users(:ryan).email, :email_confirmation => users(:ryan).email, :username => "john", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
    assert u.valid?
    assert_not_equal u.id, nil
    assert_equal u.password, Digest::MD5.hexdigest("pwd")
    # Make sure the verification email was "sent"
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
  end

  def test_should_send_forgot_password_email
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:ryan).id)
    assert_equal u.password_recovery_code, ''
    assert_nil u.password_recovery_code_set
    u.send_password_email
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
    # Check user
    u = User.find_by_id(users(:ryan).id)
    assert_not_equal u.password_recovery_code, ''
    assert_not_nil u.password_recovery_code_set
  end

  def test_should_send_verification_email_when_code_changed
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:ryan).id)
    u.update_attributes(:verification_code => 'test')
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
  end

  def test_should_send_verification_email_when_not_verified
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user2).id)
    prev_code = u.verification_code
    assert u.update_attributes(:verified => false)
    assert_not_equal prev_code, u.verification_code
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
  end

  def test_should_send_verification_email_when_forced
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user3).id)
    assert u.send_verification_email(true)
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
  end

  def test_should_not_send_verification_email_if_forced_but_no_verification_code
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:ryan).id)
    assert !u.send_verification_email(true)
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
  end

  def test_should_not_send_verification_email_if_not_forced
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user3).id)
    u.update_attributes(:first_name => u.first_name + 'xx')
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
  end

  def test_should_not_send_verification_email_if_code_cleared
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user3).id)
    u.update_attributes(:verification_code => '', :verified => true)
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
  end

  def test_should_add_new_friend
    change_constant 'send_level_two_emails', 'true'
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
    assert_equal u.inverse_friends.count, 2
    assert_equal u.inverse_friendships.count, 2
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    assert_equal u2.friends.count, 1
    assert_equal u2.friendships.count, 1
    assert_equal u2.inverse_friends.count, 4
    assert_equal u2.inverse_friendships.count, 4
    u2.add_friend(u)
    assert_equal u.friends.count, 2
    assert_equal u.inverse_friends.count, 3
    assert_equal u2.friends.count, 2
    assert_equal u2.inverse_friends.count, 4
    # Make sure it sends an email.
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
  end

  def test_should_not_add_new_friend
    change_constant 'send_level_two_emails', 'true'
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
    assert_equal u.inverse_friends.count, 2
    assert_equal u.inverse_friendships.count, 2
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    assert_equal u2.friends.count, 1
    assert_equal u2.friendships.count, 1
    assert_equal u2.inverse_friends.count, 4
    assert_equal u2.inverse_friendships.count, 4
    u.add_friend(u2)
    assert_equal u.friends.count, 2
    assert_equal u.inverse_friends.count, 2
    assert_equal u2.friends.count, 1
    assert_equal u2.inverse_friends.count, 4
    # Make sure it does not send an email.
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
  end

  def test_remove_friend
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
    u2 = User.find_by_id(users(:user2).id)
    assert_not_nil u2
    assert u.friends.include?(u2)
    assert u.remove_friend(u2)
    assert_equal u.friends.count, 1
    assert_equal u.friendships.count, 1
  end

  def test_remove_friend_failed
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
    u2 = User.find_by_id(users(:ryan).id)
    assert_not_nil u2
    assert !u.friends.include?(u2)
    assert !u.remove_friend(u2)
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
    assert !u.remove_friend(nil)
    assert_equal u.friends.count, 2
    assert_equal u.friendships.count, 2
  end

  def test_friend_collection_does_not_include_blocked
    u = User.find_by_id(users(:user3).id)
    assert u
    assert_equal u.friends.count, 3
    assert_equal u.non_blocked_friends.count, 2
  end

  def test_should_send_new_friend_request_email_level_two_on
    change_constant 'send_level_two_emails', 'true'
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:ryan).id)
    u.send_new_friend_request_email
    assert_equal num_deliveries + 1, ActionMailer::Base.deliveries.size
  end

  def test_should_not_send_new_friend_request_email_level_two_off
    change_constant 'send_level_two_emails', 'false'
    num_deliveries = ActionMailer::Base.deliveries.size
    u = User.find_by_id(users(:ryan).id)
    u.send_new_friend_request_email
    assert_equal num_deliveries, ActionMailer::Base.deliveries.size
  end

  def test_groups_association
    u = User.find_by_id(users(:ryan).id)
    assert_not_nil u.groups
    assert_equal u.groups.count, 3
    g = u.groups.find_by_id(groups(:ryan_family).id)
    assert_not_nil g
    assert g.members.count, 2
  end

  def test_new_group
    u = User.find_by_id(users(:ryan).id)
    assert_nil Group.find_by_user_id_and_group_name(users(:ryan).id, groups(:ryan_family).group_name + 'x')
    num_groups = u.groups.count
    g = u.groups.create(:name => groups(:ryan_family).group_name + 'x')
    assert_not_nil g.id
    assert_equal num_groups + 1, u.groups.count
    assert_not_nil u.groups.find_by_group_name(groups(:ryan_family).group_name + 'x')
  end

  def test_destroy_dependents_groups
    u = User.find_by_id(users(:user1).id)
    assert_not_nil u
    num = Group.find_all_by_user_id(u.id).count
    assert_not_equal 0, num
    u.destroy
    assert_not_equal num, Group.find_all_by_user_id(u.id).count
    assert_equal 0, Group.find_all_by_user_id(u.id).count
  end

end

