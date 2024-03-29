class RequestToken < OauthToken
  
  attr_accessor :provided_oauth_verifier
  
  def authorize!(user, access_level = nil)
    return false if authorized?
    self.user = user
    self.authorized_at = Time.now
    self.verifier=OAuth::Helper.generate_key(16)[0,20] unless oauth10?
    self.access_level = access_level unless access_level == nil
    self.save
  end
  
  def exchange!
    return false unless authorized?
    return false unless oauth10? || verifier==provided_oauth_verifier
    RequestToken.transaction do
      access_token = AccessToken.create(:user => user, :client_application => client_application, :access_level => access_level)
      invalidate!
      access_token
    end
  end
  
  def to_query
    if oauth10?
      super
    else
      "#{super}&oauth_callback_confirmed=true"
    end
  end
  
  def oob?
    self.callback_url=='oob'
  end
  
  def oauth10?
    (defined? OAUTH_10_SUPPORT) && OAUTH_10_SUPPORT && self.callback_url.blank?
  end

end
