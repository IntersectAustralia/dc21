class AddCreatorIdToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :creator_id, :integer
  end
end
