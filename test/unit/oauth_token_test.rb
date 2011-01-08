require File.dirname(__FILE__) + '/../test_helper'

class RequestTokenTest < ActiveSupport::TestCase

  fixtures :client_applications, :users, :oauth_tokens
  
  def setup
    @token = RequestToken.create :client_application=>client_applications(:app1)
  end

  def test_should_be_valid
    assert @token.valid?
  end
  
  def test_should_not_have_errors
    assert @token.errors.empty?
  end
  
  def test_should_have_a_token
    assert_not_nil @token.token
  end

  def test_should_have_a_secret
    assert_not_nil @token.secret
  end
  
  def test_should_not_be_authorized 
    assert !@token.authorized?
  end

  def test_should_not_be_invalidated
    assert !@token.invalidated?
  end
  
  def test_should_authorize_request
    @token.authorize!(users(:ryan))
    assert @token.authorized?
    assert_not_nil @token.authorized_at
    assert_equal users(:ryan), @token.user
    # unspecified access level should allow all
    assert @token.can_view?
    assert @token.can_edit?
    assert @token.can_delete?
  end
  
  def test_should_authorize_request_with_full_access_level
    @token.authorize!(users(:ryan), 7)
    assert @token.authorized?
    assert_not_nil @token.authorized_at
    assert_equal users(:ryan), @token.user
    assert @token.can_view?
    assert @token.can_edit?
    assert @token.can_delete?
  end
  
  def test_should_authorize_request_with_edit_access_level
    @token.authorize!(users(:ryan), 3)
    assert @token.authorized?
    assert_not_nil @token.authorized_at
    assert_equal users(:ryan), @token.user
    assert @token.can_view?
    assert @token.can_edit?
    assert !@token.can_delete?
  end
  
  def test_should_authorize_request_with_read_only_access_level
    @token.authorize!(users(:ryan), 1)
    assert @token.authorized?
    assert_not_nil @token.authorized_at
    assert_equal users(:ryan), @token.user
    assert @token.can_view?
    assert !@token.can_edit?
    assert !@token.can_delete?
  end
  
  def test_should_not_exchange_without_approval
    assert_equal false, @token.exchange!
    assert_equal false, @token.invalidated?
  end
  
  def test_should_exchange_with_approval
    @token.authorize!(users(:ryan))
    @token.provided_oauth_verifier = @token.verifier
    @access = @token.exchange!
    assert_not_equal false, @access
    assert @token.invalidated?
    
    assert_equal users(:ryan), @access.user
    assert @access.authorized?
  end

  def test_should_exchange_with_approval_full_access
    @token.authorize!(users(:ryan), 7)
    @token.provided_oauth_verifier = @token.verifier
    @access = @token.exchange!
    assert_not_equal false, @access
    assert @token.invalidated?
    assert @token.access_level, @access.access_level
    assert 7, @access.access_level
    assert @access.can_view?
    assert @access.can_edit?
    assert @access.can_delete?
    
    assert_equal users(:ryan), @access.user
    assert @access.authorized?
  end

  def test_should_exchange_with_approval_edit_access
    @token.authorize!(users(:ryan), 3)
    @token.provided_oauth_verifier = @token.verifier
    @access = @token.exchange!
    assert_not_equal false, @access
    assert @token.invalidated?
    assert @token.access_level, @access.access_level
    assert 3, @access.access_level
    assert @access.can_view?
    assert @access.can_edit?
    assert !@access.can_delete?
    
    assert_equal users(:ryan), @access.user
    assert @access.authorized?
  end

  def test_should_exchange_with_approval_read_only_access
    @token.authorize!(users(:ryan), 1)
    @token.provided_oauth_verifier = @token.verifier
    @access = @token.exchange!
    assert_not_equal false, @access
    assert @token.invalidated?
    assert @token.access_level, @access.access_level
    assert 1, @access.access_level
    assert @access.can_view?
    assert !@access.can_edit?
    assert !@access.can_delete?
    
    assert_equal users(:ryan), @access.user
    assert @access.authorized?
  end

  def test_should_authorize_access
    @token.access_level = 7 # Full Control
    assert @token.can_delete?
    assert @token.can_edit?
    assert @token.can_view?
    assert_equal @token.access_level_text, t(:access_level_7)
    @token.access_level = 6 # Delete + Edit
    assert @token.can_delete?
    assert @token.can_edit?
    assert !@token.can_view?
    assert_equal @token.access_level_text, t(:access_level_6)
    @token.access_level = 5 # Delete + View
    assert @token.can_delete?
    assert !@token.can_edit?
    assert @token.can_view?
    assert_equal @token.access_level_text, t(:access_level_5)
    @token.access_level = 4 # Only Delete
    assert @token.can_delete?
    assert !@token.can_edit?
    assert !@token.can_view?
    assert_equal @token.access_level_text, t(:access_level_4)
    @token.access_level = 3 # Edit + View
    assert !@token.can_delete?
    assert @token.can_edit?
    assert @token.can_view?
    assert_equal @token.access_level_text, t(:access_level_3)
    @token.access_level = 2 # Edit Only
    assert !@token.can_delete?
    assert @token.can_edit?
    assert !@token.can_view?
    assert_equal @token.access_level_text, t(:access_level_2)
    @token.access_level = 1 # View Only
    assert !@token.can_delete?
    assert !@token.can_edit?
    assert @token.can_view?
    assert_equal @token.access_level_text, t(:access_level_1)
    @token.access_level = 0 # None Specified
    assert !@token.can_delete?
    assert !@token.can_edit?
    assert !@token.can_view?
    assert_equal @token.access_level_text, t(:access_level_0)
    @token.access_level = -1 # Default Full Control
    assert @token.can_delete?
    assert @token.can_edit?
    assert @token.can_view?
    assert_equal @token.access_level_text, t('access_level_-1'.to_sym)
  end
  
end
