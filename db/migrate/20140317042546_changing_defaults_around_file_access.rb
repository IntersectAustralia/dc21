class ChangingDefaultsAroundFileAccess < ActiveRecord::Migration
  def up
    change_column_default :data_files, :access, "Private"
    change_column_default :data_files, :access_to_all_institutional_users, true
    DataFile.update_all(access: "Private", access_to_all_institutional_users: true)
  end
  def down
    change_column_default :data_files, :access, ""
    change_column_default :data_files, :access_to_all_institutional_users, nil
  end
end
