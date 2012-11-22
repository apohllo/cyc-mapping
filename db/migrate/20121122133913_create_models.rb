class CreateModels < ActiveRecord::Migration
  def up
    create_table "concepts" do |t|
      t.string  "name"
      t.string  "ignored",                               :default => ""
      t.integer "concept_id"
      t.integer "kind_id"
      t.string  "external"
      t.string  "english_mapping"
      t.integer "instances_count",                       :default => 0
      t.integer "native_parents_count",                         :default => 0
      t.integer "native_children_count",                        :default => 0
      t.string  "version"
      t.string  "type"
      t.boolean "isa_argument",                          :default => false
      t.boolean "genl_argument",                         :default => false
      t.boolean "relation_argument",                     :default => false
      t.boolean "umbel",                                 :default => false
      t.integer "spellings_count",                       :default => 0
      t.boolean "abstract",                              :default => false
    end

    add_index "concepts", ["native_children_count", "name"], :name => "index_concepts_on_children_count_and_name"
    add_index "concepts", ["native_children_count"], :name => "index_concepts_on_children_count"
    add_index "concepts", ["name"], :name => "index_cyc_symbols_on_name"
    add_index "concepts", ["type"], :name => "index_concepts_on_type"

    create_table :super_types do |t|
      t.string :name
      t.timestamps
    end
    add_index :super_types, :name

    create_table "concepts_super_types", :id => false do |t|
      t.integer "concept_id"
      t.integer "super_type_id"
    end

    add_index "concepts_super_types", ["concept_id", "super_type_id"],
      :name => "index_concepts_super_types_on_concept_id_and_super_type_id"
    add_index "concepts_super_types", ["concept_id"],
      :name => "index_concepts_super_types_on_concept_id"
    add_index "concepts_super_types", ["super_type_id"],
      :name => "index_concepts_super_types_on_super_type_id"

    create_table "log_entries" do |t|
      t.integer  "user_id"
      t.string   "controller"
      t.string   "action"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "log_entries", ["user_id"], :name => "index_log_entries_on_user_id"

    create_table "parentships" do |t|
      t.integer  "parent_id"
      t.integer  "child_id"
      t.string   "status",        :default => "extracted"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "parentships", ["child_id"],
      :name => "index_parentships_on_child_id"
    add_index "parentships", ["parent_id", "child_id"],
      :name => "index_parentships_on_parent_id_and_child_id", :unique => true
    add_index "parentships", ["parent_id"],
      :name => "index_parentships_on_parent_id"

    create_table "segments" do |t|
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "spelling_id"
      t.string   "value"
      t.boolean  "nominal"
    end

    add_index "segments", ["spelling_id"], :name => "index_segments_on_spelling_id"

    create_table "spellings" do |t|
      t.integer  "concept_id"
      t.string   "name"
      t.integer  "position",         :default => 0
      t.string   "status"
      t.integer  "created_by_id"
      t.integer  "updated_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "spellings", ["concept_id"], :name => "index_spellings_on_concept_id"
  end

  def down
    drop_table "spellings"
    drop_table "segments"
    drop_table "parentships"
    drop_table "log_entries"
    drop_table "concepts_super_types"
    drop_table "concepts"
    drop_table "super_types"
  end
end
