class DataFilesToTagsTable < ActiveRecord::Migration
  def change
    create_table :data_files_tags, :id => false do |t|
      t.integer :data_file_id
      t.integer :tag_id
    end
  end
end
