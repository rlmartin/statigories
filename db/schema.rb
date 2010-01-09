# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091219180409) do

  create_table "constants", :force => true do |t|
    t.string   "name",        :default => ""
    t.string   "value",       :default => ""
    t.string   "server_type", :default => ""
    t.string   "lang",        :default => ""
    t.string   "cast_as",     :default => ""
    t.boolean  "array",       :default => false
    t.boolean  "active",      :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "constants", ["active"], :name => "index_constants_on_active"
  add_index "constants", ["cast_as"], :name => "index_constants_on_cast_as"
  add_index "constants", ["lang"], :name => "index_constants_on_lang"
  add_index "constants", ["name"], :name => "index_constants_on_name"
  add_index "constants", ["server_type", "active", "name"], :name => "index_constants_on_server_type_and_active_and_name"
  add_index "constants", ["server_type", "active"], :name => "index_constants_on_server_type_and_active"
  add_index "constants", ["server_type"], :name => "index_constants_on_server_type"

  create_table "event_log_extras", :force => true do |t|
    t.integer  "event_log_id", :null => false
    t.text     "data",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_logs", :force => true do |t|
    t.integer  "event_id",                      :null => false
    t.integer  "user_id"
    t.integer  "user_agent_id",                 :null => false
    t.string   "event_data",    :default => "", :null => false
    t.string   "ip_address",    :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name",        :default => "", :null => false
    t.string   "description", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "friend_id",                     :null => false
    t.boolean  "responded",  :default => false, :null => false
    t.boolean  "blocked",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["friend_id"], :name => "index_friendships_on_friend_id"
  add_index "friendships", ["user_id", "friend_id"], :name => "index_friendships_on_user_id_and_friend_id", :unique => true
  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "user_agents", :force => true do |t|
    t.string   "user_agent", :default => "",    :null => false
    t.boolean  "is_bot",     :default => false, :null => false
    t.boolean  "is_mobile",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_agents", ["user_agent"], :name => "index_user_agents_on_user_agent", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                         :null => false
    t.string   "username",                                      :null => false
    t.string   "password"
    t.string   "first_name",                 :default => ""
    t.string   "last_name",                  :default => ""
    t.boolean  "verified",                   :default => false
    t.string   "verification_code",          :default => ""
    t.string   "password_recovery_code",     :default => ""
    t.date     "password_recovery_code_set"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
