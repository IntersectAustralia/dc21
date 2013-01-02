class AddPublishedToDataFiles < ActiveRecord::Migration
  def up
    add_column :data_files, :published, :boolean, :default => false
  end

  def down
    remove_column :data_files, :published
  end
end
