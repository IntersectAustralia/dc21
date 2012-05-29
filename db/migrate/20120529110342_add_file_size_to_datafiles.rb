class AddFileSizeToDatafiles < ActiveRecord::Migration
  def change
    add_column :data_files, :file_size, :integer
  end
end
