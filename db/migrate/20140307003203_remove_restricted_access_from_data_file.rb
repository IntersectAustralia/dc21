class RemoveRestrictedAccessFromDataFile < ActiveRecord::Migration
  def change
    remove_column :data_files, :restricted_access
  end
end
