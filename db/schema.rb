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

ActiveRecord::Schema.define(:version => 20110113125719) do

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 20
    t.string   "secret",       :limit => 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

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

  create_table "group_memberships", :force => true do |t|
    t.integer  "group_id",      :null => false
    t.integer  "friendship_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_memberships", ["friendship_id"], :name => "index_group_memberships_on_friendship_id"
  add_index "group_memberships", ["group_id", "friendship_id"], :name => "index_group_memberships_on_group_id_and_friendship_id", :unique => true
  add_index "group_memberships", ["group_id"], :name => "index_group_memberships_on_group_id"

  create_table "groups", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.string   "name",       :default => "", :null => false
    t.string   "group_name", :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["user_id", "group_name"], :name => "index_groups_on_user_id_and_group_name", :unique => true
  add_index "groups", ["user_id"], :name => "index_groups_on_user_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "user_id",                         :null => false
    t.string   "label",        :default => "",    :null => false
    t.integer  "access_level", :default => 1,     :null => false
    t.date     "date",                            :null => false
    t.integer  "index",        :default => 0,     :null => false
    t.integer  "integer",      :default => 0,     :null => false
    t.boolean  "deleted",      :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_entries", ["user_id", "access_level", "deleted"], :name => "index_log_entries_on_user_id_and_access_level_and_deleted"
  add_index "log_entries", ["user_id", "index"], :name => "index_log_entries_on_user_id_and_index", :unique => true
  add_index "log_entries", ["user_id"], :name => "index_log_entries_on_user_id"

  create_table "log_entry_items", :force => true do |t|
    t.integer  "log_entry_id",                                                     :null => false
    t.text     "value",                                                            :null => false
    t.integer  "display_order",                                 :default => 1,     :null => false
    t.boolean  "deleted",                                       :default => false, :null => false
    t.integer  "value_int"
    t.float    "value_float"
    t.datetime "value_date"
    t.boolean  "value_bool"
    t.decimal  "value_lat",     :precision => 22, :scale => 17
    t.decimal  "value_lng",     :precision => 22, :scale => 17
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_entry_items", ["log_entry_id", "deleted"], :name => "index_log_entry_items_on_log_entry_id_and_deleted"
  add_index "log_entry_items", ["log_entry_id"], :name => "index_log_entry_items_on_log_entry_id"

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 20
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "access_level",                        :default => -1
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

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
