class CreateEventLogExtras < ActiveRecord::Migration
  def self.up
    create_table :event_log_extras do |t|
      t.integer :event_log_id, :null => false
      t.text :data, :null => false, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :event_log_extras
  end
end
