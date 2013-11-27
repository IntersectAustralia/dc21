class RemoveConvertedTextFromDataFiles < ActiveRecord::Migration
  def change
    remove_column :data_files, :converted_text
  end
end
