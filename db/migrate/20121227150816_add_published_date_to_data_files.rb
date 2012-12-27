class AddPublishedDateToDataFiles < ActiveRecord::Migration
  def up
    add_column :data_files, :published_date, :datetime
  end

  def down
    remove_column :data_files, :published_date
  end
end
