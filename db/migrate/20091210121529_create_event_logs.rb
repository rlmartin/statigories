class CreateEventLogs < ActiveRecord::Migration
  def self.up
    create_table :event_logs do |t|
      t.integer :event_id, :null => false
      t.integer :user_id
      t.integer :user_agent_id, :null => false
      t.string :event_data, :null => false, :default => ""
      t.string :ip_address, :null => false, :default => ""

      t.timestamps
    end
  end

  def self.down
    drop_table :event_logs
  end
end
