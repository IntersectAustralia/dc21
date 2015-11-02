class AddRegistryObjectToSystemConfig < ActiveRecord::Migration
  def change
    add_column :system_configurations, :registry_object_group, :string, :default => ''
  end
end
