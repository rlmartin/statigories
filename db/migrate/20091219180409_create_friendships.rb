class CreateFriendships < ActiveRecord::Migration
  def self.up
    create_table :friendships do |t|
      t.integer :user_id, :null => false
      t.integer :friend_id, :null => false
      t.boolean :responded, :null => false, :default => false
      t.boolean :blocked, :null => false, :default => false

      t.timestamps
    end
	  add_index :friendships, [:user_id]
	  add_index :friendships, [:friend_id]
	  add_index :friendships, [:user_id, :friend_id], :unique => true
  end

  def self.down
    drop_table :friendships
  end
end
