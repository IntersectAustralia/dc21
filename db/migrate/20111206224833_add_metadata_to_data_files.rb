class AddMetadataToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :metadata, :text
  end
end
