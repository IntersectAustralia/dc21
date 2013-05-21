class ChangePathToText < ActiveRecord::Migration
  def up
  	change_column :data_files, :path, :text
  end

  def down
  	change_column :data_files, :path, :string
  end
end
