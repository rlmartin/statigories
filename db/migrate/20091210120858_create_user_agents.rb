class CreateUserAgents < ActiveRecord::Migration
  def self.up
    create_table :user_agents do |t|
      t.string :user_agent, :null => false, :default => ""
      t.boolean :is_bot, :null => false, :default => 0
      t.boolean :is_mobile, :null => false, :default => 0

      t.timestamps
    end
    add_index :user_agents, [:user_agent], :unique => true
  end

  def self.down
    drop_table :user_agents
  end
end
