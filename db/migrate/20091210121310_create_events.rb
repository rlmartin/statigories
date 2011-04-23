class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :name, :null => false, :default => ""
      t.string :description, :null => false, :default => ""

      t.timestamps
    end
	  Event.create(:name => 'login', :description => 'User login')
	  Event.create(:name => 'logout', :description => 'User logout')
	  Event.create(:name => 'email_msg_sent', :description => 'Email message sent')
	  Event.create(:name => 'user_deleted', :description => 'User deleted')
	  Event.create(:name => 'user_edited', :description => 'User profile edited')
  end

  def self.down
    drop_table :events
  end
end
