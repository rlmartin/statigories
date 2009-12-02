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

ActiveRecord::Schema.define(:version => 20091121201534) do

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
