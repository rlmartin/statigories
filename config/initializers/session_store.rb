# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mylo.gs_session',
  :secret      => 'e25f91791b0790d3db5de9e74073c71aca8adabf7d70b816f612312ed0a1dc3661e06fcdf9a530577c78fb8ee8202339ff254562049398404e7a7c6a4602c280'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
