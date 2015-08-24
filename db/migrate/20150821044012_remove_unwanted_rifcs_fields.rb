class RemoveUnwantedRifcsFields < ActiveRecord::Migration
  def change
    remove_column :system_configurations, :open_access_rights_uri
    remove_column :system_configurations, :conditional_access_rights_uri
    remove_column :system_configurations, :restricted_access_rights_uri
  end
end
