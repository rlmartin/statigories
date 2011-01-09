class EventLog < ActiveRecord::Base
  include ArgsLib
  attr_accessor :_extra
  belongs_to :user_agent
  belongs_to :event
  has_many :event_log_extras
  belongs_to :user
  validates_presence_of [:event_id, :user_agent_id]
  before_validation :set_request_data
  before_save :_process_data_before
  after_save :_process_data_after

  def set_request_data(request = nil)
    # Make sure there is a default request
    if request == nil: request = @@_req end
    if request == nil: request = { :remote_ip => '', :user_agent => '' } end
    _ua = ''
    _ip = ''
    if request.is_a?(Hash)
      _ua = request[:user_agent]
      _ip = request[:remote_ip]
    else
      _ua = request.user_agent
      _ip = request.remote_ip
    end
    if self.user_agent_id == nil
      ua = UserAgent.find_by_user_agent(_ua)
      if ua == nil: ua = UserAgent.create(:user_agent => _ua) end
      self.user_agent_id = ua.id
      ua = nil
    end

    if self.ip_address == nil or self.ip_address == '': self.ip_address = _ip end
  end

  private
  def _process_data_before
    # Automatically detect whether or not to push the data into the extra table.
    if self.event_data == nil: self.event_data = '' end
    if self.event_data.length > 255
      self._extra = self.event_data
      self.event_data = ''
    end
  end

  def _process_data_after
    # Automatically detect whether or not to push the data into the extra table.
    if self.id != nil and self._extra != nil and self._extra != '': self.event_log_extras.create(:data => self._extra) end
  end
end
