class AddRestrictedAccessToDatafile < ActiveRecord::Migration
  def change
    add_column :data_files, :restricted_access, :boolean
  end
end
