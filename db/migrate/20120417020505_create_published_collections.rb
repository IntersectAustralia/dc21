class CreatePublishedCollections < ActiveRecord::Migration
  def change
    create_table :published_collections do |t|
      t.string :name
      t.integer :created_by_id
      t.string :rif_cs_file_path
      t.string :zip_file_path

      t.timestamps
    end
  end
end
