class AddPublishedByIdToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :published_by_id, :integer
  end
end
