class AddStartAndEndTimesToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :start_time, :datetime
    add_column :data_files, :end_time, :datetime
  end
end
