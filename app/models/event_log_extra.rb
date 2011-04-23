class EventLogExtra < ActiveRecord::Base
  belongs_to :event_log
  xss_terminate :except => [:data]
end
