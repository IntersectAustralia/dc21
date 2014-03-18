class ChangingDefaultsAroundFileAccess < ActiveRecord::Migration
  def change
      change_column_default :data_files, :access, "Private"
      change_column_default :data_files, :access_to_all_institutional_users, true
  end
end
