class ChangeFileSizeToFloat < ActiveRecord::Migration
  def up
    change_column :data_files, :file_size, :float
  end

  def down
    change_column :my_table, :file_size, :integer
  end
end
