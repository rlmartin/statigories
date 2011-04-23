class CreateLogEntries < ActiveRecord::Migration
  def self.up
    create_table :log_entries do |t|
      t.integer :user_id, :null => false
      t.string :label, :null => false, :default => ''
      t.integer :access_level, :null => false, :default => 1
      t.date :date, :null => false
      t.integer :index, :integer, :null => false, :default => 0
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end
	  add_index :log_entries, [:user_id]
	  add_index :log_entries, [:user_id, :access_level, :deleted]
	  add_index :log_entries, [:user_id, :index], :unique => true
  end

  def self.down
    drop_table :log_entries
  end
end
