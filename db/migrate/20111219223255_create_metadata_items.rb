class CreateMetadataItems < ActiveRecord::Migration
  def change
    create_table :metadata_items do |t|
      t.string :key
      t.string :value
      t.references :data_file

      t.timestamps
    end
    add_index :metadata_items, :data_file_id
  end
end
