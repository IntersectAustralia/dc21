class DropMetadataFromDataFiles < ActiveRecord::Migration
  def up
    remove_column :data_files, :metadata
  end

  def down
    add_column :data_files, :metadata, :text
  end
end
