class AddStatusFieldsToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :file_processing_status, :string
    add_column :data_files, :file_processing_description, :string
  end
end
