class AddCreatedByToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :created_by_id, :integer
  end
end
