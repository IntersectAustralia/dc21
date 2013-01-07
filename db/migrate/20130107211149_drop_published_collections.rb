class DropPublishedCollections < ActiveRecord::Migration
  def up
    drop_table :published_collections
  end

  def down
    create_table "published_collections" do |t|
      t.string "name"
      t.integer "created_by_id"
      t.string "rif_cs_file_path"
      t.string "zip_file_path"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "description"
    end

  end
end
