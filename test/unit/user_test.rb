require 'test_helper'

class UserTest < ActiveSupport::TestCase

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
    u = User.create(:email => "johndoe@xxgmailxx.com", :email_confirmation => "johndoe@xxgmailxx.com", :username => "john", :password => "pwd", :password_confirmation => "pwd", :first_name => "John", :last_name => "Doe")
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

end
