class LogEntryItem < ActiveRecord::Base
  include StringLib
  acts_as_taggable
  belongs_to :log_entry
  validates_presence_of [:log_entry_id, :value]
  xss_terminate :except => [:value]
  before_validation :set_values

  protected
  def set_values
    self.value_bool = nil
    self.value_date = nil
    self.value_float = nil
    self.value_int = nil
    self.value_lat = nil
    self.value_lng = nil
    self.value_bool = StringLib.cast(self.value, :bool) if StringLib.is_bool?(self.value)
    self.value_date = StringLib.cast(self.value, :datetime) if StringLib.is_date?(self.value)
    self.value_float = StringLib.cast(self.value, :float) if StringLib.is_float?(self.value)
    self.value_int = StringLib.cast(self.value, :int) if StringLib.is_int?(self.value)
    if StringLib.is_point?(self.value)
      self.value_lat = StringLib.cast(self.value, :point_x)
      self.value_lng = StringLib.cast(self.value, :point_y)
    end
    self.tag_list = self.tag_list.join(', ').downcase
  end
end
