class Event < ActiveRecord::Base
  has_many :event_logs

  LOGIN = 1
  LOGOUT = 2
  EMAIL_MSG_SENT = 3
  USER_DELETED = 4
  USER_EDITED = 5
end
