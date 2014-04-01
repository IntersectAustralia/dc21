class AddPublicPrivateAccessToDataFile < ActiveRecord::Migration
  def up
    add_column :data_files, :access, :text
    add_column :data_files, :access_to_all_institutional_users, :bool
    add_column :data_files, :access_to_user_groups, :bool
  end
  def down
    remove_column :data_files, :access
    remove_column :data_files, :access_to_all_institutional_users
    remove_column :data_files, :access_to_user_groups
  end
end
