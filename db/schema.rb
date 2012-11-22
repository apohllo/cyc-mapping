# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121122133913) do

  create_table "concepts", :force => true do |t|
    t.string  "name"
    t.string  "ignored",               :default => ""
    t.integer "concept_id"
    t.integer "kind_id"
    t.string  "external"
    t.string  "english_mapping"
    t.integer "instances_count",       :default => 0
    t.integer "native_parents_count",  :default => 0
    t.integer "native_children_count", :default => 0
    t.string  "version"
    t.string  "type"
    t.boolean "isa_argument",          :default => false
    t.boolean "genl_argument",         :default => false
    t.boolean "relation_argument",     :default => false
    t.boolean "umbel",                 :default => false
    t.integer "spellings_count",       :default => 0
    t.boolean "abstract",              :default => false
  end

  add_index "concepts", ["name"], :name => "index_cyc_symbols_on_name"
  add_index "concepts", ["native_children_count", "name"], :name => "index_concepts_on_children_count_and_name"
  add_index "concepts", ["native_children_count"], :name => "index_concepts_on_children_count"
  add_index "concepts", ["type"], :name => "index_concepts_on_type"

  create_table "concepts_super_types", :id => false, :force => true do |t|
    t.integer "concept_id"
    t.integer "super_type_id"
  end

  add_index "concepts_super_types", ["concept_id", "super_type_id"], :name => "index_concepts_super_types_on_concept_id_and_super_type_id"
  add_index "concepts_super_types", ["concept_id"], :name => "index_concepts_super_types_on_concept_id"
  add_index "concepts_super_types", ["super_type_id"], :name => "index_concepts_super_types_on_super_type_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "user_id"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "log_entries", ["user_id"], :name => "index_log_entries_on_user_id"

  create_table "parentships", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "child_id"
    t.string   "status",        :default => "extracted"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "parentships", ["child_id"], :name => "index_parentships_on_child_id"
  add_index "parentships", ["parent_id", "child_id"], :name => "index_parentships_on_parent_id_and_child_id", :unique => true
  add_index "parentships", ["parent_id"], :name => "index_parentships_on_parent_id"

  create_table "segments", :force => true do |t|
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "spelling_id"
    t.string   "value"
    t.boolean  "nominal"
  end

  add_index "segments", ["spelling_id"], :name => "index_segments_on_spelling_id"

  create_table "spellings", :force => true do |t|
    t.integer  "concept_id"
    t.string   "name"
    t.integer  "position",      :default => 0
    t.string   "status"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spellings", ["concept_id"], :name => "index_spellings_on_concept_id"

  create_table "super_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "super_types", ["name"], :name => "index_super_types_on_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
