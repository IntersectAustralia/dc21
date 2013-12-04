class RenameDataFilesLabelsToDataFileLabels < ActiveRecord::Migration
  def up
    rename_table :data_files_labels, :data_file_labels
  end

  def down
    rename_table :data_file_labels, :data_files_labels
  end
end
