class AddIntervalToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :interval, :integer
  end
end
