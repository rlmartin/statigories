class CreateGroupMemberships < ActiveRecord::Migration
  def self.up
    create_table :group_memberships do |t|
      t.integer :group_id, :null => false
      t.integer :friendship_id, :null => false

      t.timestamps
    end
	  add_index :group_memberships, [:group_id]
	  add_index :group_memberships, [:friendship_id]
	  add_index :group_memberships, [:group_id, :friendship_id], :unique => true
  end

  def self.down
    drop_table :group_memberships
  end
end
