class ChangeDataFileDescription < ActiveRecord::Migration
  def up
    change_column :data_files, :file_processing_description, :text
  end

  def down
    change_column :data_files, :file_processing_description, :string
  end
end
