class LogEntry < ActiveRecord::Base
  acts_as_taggable
  belongs_to :user
  has_many :items, :class_name => "LogEntryItem", :dependent => :destroy
  attr_readonly :index
  validates_presence_of [:user_id, :access_level, :date]
  before_validation [:check_access_level, :check_date, :set_entry_index]
  before_save :set_tags
  PUBLIC = 1
  ANONYMOUS = 0
  PRIVATE = -1

  protected
  def check_access_level
    # Default access_level = 1 (public)
    if self.access_level == nil or self.access_level < -1 or self.access_level > 1: self.access_level = PUBLIC end
  end

  def check_date
    if self.date == nil: self.date = Time.now end
  end

  def set_entry_index
    previous = nil
    unless self.user == nil: previous = self.user.log_entries.find(:first, :order => '`index` DESC') end
    # Only set the index once, when it is a new entry.
    if self.index == nil or self.id == nil
      self.index = 1
      unless previous == nil: self.index = previous.index + 1 end
    end
  end

  def set_tags
    self.tag_list = self.label.gsub(',', '').split(' ')
  end
end
