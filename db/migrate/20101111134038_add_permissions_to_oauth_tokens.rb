class AddPermissionsToOauthTokens < ActiveRecord::Migration
  def self.up
    add_column :oauth_tokens, :access_level, :integer, :default => -1
  end

  def self.down
    remove_column :oauth_tokens, :access_level
  end
end
