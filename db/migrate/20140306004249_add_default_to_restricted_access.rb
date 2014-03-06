class AddDefaultToRestrictedAccess < ActiveRecord::Migration
  def change
    change_column_default :data_files, :restricted_access, false
  end
end
