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

ActiveRecord::Schema.define(:version => 20121121165507) do

  create_table "concepts", :force => true do |t|
    t.string  "name"
    t.string  "ignored",                               :default => ""
    t.integer "concept_id"
    t.integer "kind_id"
    t.string  "external"
    t.string  "english_mapping"
    t.integer "instances_count"
    t.integer "parents_count"
    t.integer "children_count"
    t.boolean "root",                                  :default => false
    t.string  "version"
    t.boolean "abstract",                              :default => false
    t.string  "comment",               :limit => 8192
    t.string  "type"
    t.integer "pohl_concept_id"
    t.integer "native_children_count",                 :default => 0
    t.integer "native_parents_count",                  :default => 0
    t.boolean "isa_argument",                          :default => false
    t.boolean "genl_argument",                         :default => false
    t.string  "dbpedia_link"
    t.string  "opencyc_id"
    t.string  "wikipedia_kinds"
    t.text    "wikipedia_categories"
    t.boolean "relation_argument",                     :default => false
    t.boolean "umbel",                                 :default => false
    t.integer "spellings_count"
  end

  add_index "concepts", ["children_count", "name"], :name => "index_concepts_on_children_count_and_name"
  add_index "concepts", ["children_count"], :name => "index_concepts_on_children_count"
  add_index "concepts", ["dbpedia_link"], :name => "index_concepts_on_dbpedia_link"
  add_index "concepts", ["name"], :name => "index_cyc_symbols_on_name"
  add_index "concepts", ["opencyc_id"], :name => "index_concepts_on_opencyc_id"
  add_index "concepts", ["type"], :name => "index_concepts_on_type"

  create_table "concepts_super_types", :id => false, :force => true do |t|
    t.integer "concept_id"
    t.integer "super_type_id"
  end

  add_index "concepts_super_types", ["concept_id", "super_type_id"], :name => "index_concepts_super_types_on_concept_id_and_super_type_id"
  add_index "concepts_super_types", ["concept_id"], :name => "index_concepts_super_types_on_concept_id"
  add_index "concepts_super_types", ["super_type_id"], :name => "index_concepts_super_types_on_super_type_id"

  create_table "evaluations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "example_id"
    t.string   "value",      :default => "none"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",   :default => 0
  end

  add_index "evaluations", ["example_id", "value"], :name => "index_evaluations_on_example_id_and_value"
  add_index "evaluations", ["example_id"], :name => "index_evaluations_on_example_id"
  add_index "evaluations", ["position", "user_id", "value"], :name => "index_evaluations_on_position_and_user_id_and_value"
  add_index "evaluations", ["user_id", "example_id"], :name => "index_evaluations_on_user_id_and_example_id", :unique => true
  add_index "evaluations", ["user_id", "value"], :name => "index_evaluations_on_user_id_and_value"
  add_index "evaluations", ["user_id"], :name => "index_evaluations_on_user_id"

  create_table "example_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "example_groups", ["name"], :name => "index_example_groups_on_name", :unique => true

  create_table "example_patterns", :force => true do |t|
    t.string   "selected_features"
    t.integer  "relation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "source_example_id"
  end

  create_table "examples", :force => true do |t|
    t.integer  "index"
    t.string   "query"
    t.integer  "corpus_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "first_offset"
    t.integer  "first_length"
    t.integer  "first_argument_id"
    t.integer  "second_offset"
    t.integer  "second_length"
    t.integer  "second_argument_id"
    t.integer  "relation_id"
    t.boolean  "positive"
    t.string   "fingerprint"
    t.integer  "group_id"
    t.string   "status"
  end

  add_index "examples", ["fingerprint", "relation_id"], :name => "index_examples_on_fingerprint_and_relation_id", :unique => true
  add_index "examples", ["first_argument_id"], :name => "index_examples_on_first_argument_id"
  add_index "examples", ["group_id"], :name => "index_examples_on_group_id"
  add_index "examples", ["relation_id"], :name => "index_examples_on_relation_id"
  add_index "examples", ["second_argument_id"], :name => "index_examples_on_second_argument_id"

  create_table "examples_features", :id => false, :force => true do |t|
    t.integer "example_id"
    t.integer "feature_id"
  end

  add_index "examples_features", ["example_id", "feature_id"], :name => "index_examples_features_on_example_id_and_feature_id", :unique => true
  add_index "examples_features", ["example_id"], :name => "index_examples_features_on_example_id"
  add_index "examples_features", ["feature_id"], :name => "index_examples_features_on_feature_id"

  create_table "features", :force => true do |t|
    t.string "name"
    t.string "value"
  end

  add_index "features", ["name", "value"], :name => "index_features_on_name_and_value", :unique => true
  add_index "features", ["name"], :name => "index_features_on_name"
  add_index "features", ["value"], :name => "index_features_on_value"

  create_table "lexemes", :force => true do |t|
    t.string  "base_form"
    t.string  "status",           :default => "new"
    t.string  "inflection_label"
    t.integer "clp_id",                              :null => false
    t.string  "clp_version"
    t.integer "concepts_count"
    t.text    "concepts_stats"
  end

  add_index "lexemes", ["base_form", "inflection_label"], :name => "index_lexemes_on_base_form_and_inflection_label", :unique => true
  add_index "lexemes", ["clp_id"], :name => "index_lexemes_on_clp_id", :unique => true
  add_index "lexemes", ["status"], :name => "index_lexemes_on_status_id"

  create_table "log_entries", :force => true do |t|
    t.integer  "user_id"
    t.string   "controller"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mappings", :force => true do |t|
    t.integer  "cyc_symbol_id"
    t.integer  "mappable_id"
    t.string   "mappable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mappings", ["cyc_symbol_id", "mappable_id", "mappable_type"], :name => "mappings_main_key"
  add_index "mappings", ["cyc_symbol_id"], :name => "index_mappings_on_cyc_symbol_id"
  add_index "mappings", ["mappable_id", "mappable_type"], :name => "index_mappings_on_mappable_id_and_mappable_type"
  add_index "mappings", ["mappable_id"], :name => "index_mappings_on_mappable_id"

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

  create_table "relations", :force => true do |t|
    t.integer "concept_id", :null => false
    t.integer "relata_id",  :null => false
    t.string  "name",       :null => false
    t.string  "status"
  end

  add_index "relations", ["name", "concept_id", "relata_id"], :name => "index_relations"

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
    t.string   "declination"
    t.string   "pos_label"
    t.integer  "pohl_spelling_id"
    t.integer  "position",         :default => 0
    t.string   "status"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spellings", ["concept_id"], :name => "index_spellings_on_concept_id"

  create_table "super_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "super_types", ["name"], :name => "index_super_types_on_name"

  create_table "synonyms", :force => true do |t|
    t.string   "namespace"
    t.string   "name"
    t.integer  "concept_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain"
    t.integer  "range"
  end

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

  create_table "word_forms", :force => true do |t|
    t.string   "value"
    t.integer  "position"
    t.integer  "lexeme_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_forms", ["lexeme_id"], :name => "index_word_forms_on_lexeme_id"
  add_index "word_forms", ["value"], :name => "index_word_forms_on_value"

end
