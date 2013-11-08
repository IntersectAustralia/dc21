class AddConvertedTextToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :converted_text, :text
  end
end
