class LogEntry < ActiveRecord::Base
  acts_as_taggable
  belongs_to :user
  has_many :items, :class_name => "LogEntryItem", :dependent => :destroy
  attr_readonly :index
  validates_presence_of [:user_id, :access_level, :date]
  before_validation :check_access_level, :check_date, :set_entry_index
  before_save :set_tags
  PUBLIC = 1
  ANONYMOUS = 0
  PRIVATE = -1

  def active_items
    items.where('deleted = 0').order('display_order')
  end

  protected
  def check_access_level
    # Default access_level = 1 (public)
    self.access_level = PUBLIC if self.access_level == nil or self.access_level < -1 or self.access_level > 1
  end

  def check_date
    self.date = Time.now if self.date == nil
  end

  def set_entry_index
    previous = nil
    previous = self.user.log_entries.order('`index` DESC').first unless self.user == nil
    # Only set the index once, when it is a new entry.
    if self.index == nil or self.id == nil
      self.index = 1
      self.index = previous.index + 1 unless previous == nil
    end
  end

  def set_tags
    self.tag_list = self.label.downcase.gsub(',', '').split(' ')
  end
end
