class RefineSegments < ActiveRecord::Migration
  def up
    remove_column :segments, :lexeme_id
    remove_column :segments, :tags
    add_column  :segments, :value, :string
    add_column  :segments, :nominal, :boolean
  end

  def down
    remove_column :segments, :nominal
    remove_column :segments, :value
    add_column :segments, :tags
    add_column :segments, :lexeme_id
  end
end
