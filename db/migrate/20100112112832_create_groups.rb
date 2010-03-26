class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.integer :user_id, :null => false
      t.string :name, :null => false, :default => ''
      t.string :group_name, :null => false, :default => ''

      t.timestamps
    end
	  add_index :groups, [:user_id]
	  add_index :groups, [:user_id, :group_name], :unique => true
  end

  def self.down
    drop_table :groups
  end
end
