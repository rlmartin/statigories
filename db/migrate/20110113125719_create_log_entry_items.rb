class CreateLogEntryItems < ActiveRecord::Migration
  def self.up
    create_table :log_entry_items do |t|
      t.integer :log_entry_id, :null => false
      t.text :value, :null => false, :default => ''
      t.integer :display_order, :null => false, :default => 1
      t.boolean :deleted, :null => false, :default => 0
      t.integer :value_int
      t.float :value_float
      t.datetime :value_date
      t.boolean :value_bool
      t.column :value_lat, :decimal, :precision => 22, :scale => 17
      t.column :value_lng, :decimal, :precision => 22, :scale => 17

      t.timestamps
    end
	  add_index :log_entry_items, [:log_entry_id]
	  add_index :log_entry_items, [:log_entry_id, :deleted]
  end

  def self.down
    drop_table :log_entry_items
  end
end
