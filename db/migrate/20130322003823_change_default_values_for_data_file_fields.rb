class ChangeDefaultValuesForDataFileFields < ActiveRecord::Migration
  def change
    change_column_default :data_files, :filename, ""
    change_column_default :data_files, :external_id, ""
    change_column_default :data_files, :file_processing_description, ""

    DataFile.find_each do |data_file|
      data_file.update_attribute(:filename, "") if data_file.filename.nil?
      data_file.update_attribute(:external_id, "") if data_file.external_id.nil?
      data_file.update_attribute(:file_processing_description, "") if data_file.file_processing_description.nil?
    end
  end
end
