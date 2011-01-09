class OauthToken < ActiveRecord::Base
  belongs_to :client_application
  belongs_to :user
  validates_uniqueness_of :token
  validates_presence_of :client_application, :token, :secret
  before_validation_on_create :generate_keys

  def access_level_text(level = nil)
    level = self.access_level unless level != nil
    begin
      I18n.t("access_level_#{level}".to_sym)
    rescue
      I18n.t(:access_level_default)
    end
  end

  def can_delete?
    # 100
    match_access?(4)
  end

  def can_edit?
    # 010
    match_access?(2)
  end

  def can_view?
    # 001
    match_access?(1)
  end

  def match_access?(level)
    # Each component of the access_level is mapped to a bit.
    # This will indicate if the access_level is allowed by the token.
    return true if access_level == -1
    ((access_level & level) == level)
  end

  def invalidated?
    invalidated_at != nil
  end
  
  def invalidate!
    update_attribute(:invalidated_at, Time.now)
  end
  
  def authorized?
    authorized_at != nil && !invalidated?
  end
    
  def to_query
    "oauth_token=#{token}&oauth_token_secret=#{secret}"
  end
    
  protected
  
  def generate_keys
    oauth_token = client_application.oauth_server.generate_credentials
    self.token = oauth_token[0][0,20]
    self.secret = oauth_token[1][0,40]
  end
end
