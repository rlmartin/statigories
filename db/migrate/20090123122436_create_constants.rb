class CreateConstants < ActiveRecord::Migration
  def self.up
    create_table :constants do |t|
      t.string :name, :default => ""
      t.string :value, :default => ""
      t.string :server_type, :default => ""
      t.string :lang, :default => ""
      t.string :cast_as, :default => ""
      t.boolean :array, :default => false
      t.boolean :active, :default => true

      t.timestamps
    end
	  add_index :constants, :server_type
	  add_index :constants, :active
	  add_index :constants, [:server_type, :active]
	  add_index :constants, [:server_type, :active, :name]
	  add_index :constants, :name
	  add_index :constants, :lang
	  add_index :constants, :cast_as

    Constant.create([
      {:name => "server_type", :value => "dev", :active => true},
      {:name => "server_type", :value => "prod", :active => false},
      {:name => "server_type", :value => "test", :active => false}
    ])
  end

  def self.down
    drop_table :constants
  end
end
