class AddPublicPrivateAccessToDataFile < ActiveRecord::Migration
  def change
    add_column :data_files, :access, :text
    add_column :data_files, :access_to_all_institutional_users, :bool
    add_column :data_files, :access_to_user_groups, :bool
  end
end
