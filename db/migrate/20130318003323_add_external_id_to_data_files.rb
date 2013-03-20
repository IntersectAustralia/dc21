class AddExternalIdToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :external_id, :text
  end
end
