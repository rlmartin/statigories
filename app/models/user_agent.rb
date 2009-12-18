class UserAgent < ActiveRecord::Base
  has_many :event_logs
end
