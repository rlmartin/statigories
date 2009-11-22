class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email, :null => false
			t.string :username, :null => false
      t.string :password
      t.string :first_name, :default => ""
      t.string :last_name, :default => ""
      t.boolean :verified, :default => false
			t.string :verification_code, :default => ""

      t.timestamps
    end
		add_index :users, :email, :unique => true
		add_index :users, :username, :unique => true
  end

  def self.down
    drop_table :users
  end
end
