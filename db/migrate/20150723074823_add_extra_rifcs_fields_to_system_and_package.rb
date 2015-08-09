class AddExtraRifcsFieldsToSystemAndPackage < ActiveRecord::Migration
  def change
    add_column :system_configurations, :language, :string
    add_column :system_configurations, :open_access_rights_uri, :text, limit: 10000
    add_column :system_configurations, :conditional_access_rights_uri, :text, limit: 10000
    add_column :system_configurations, :restricted_access_rights_uri, :text, limit: 10000
    add_column :system_configurations, :rights_statement, :text, limit: 10000
    add_column :system_configurations, :max_package_size, :float
    add_column :system_configurations, :max_package_size_unit, :string
    add_column :system_configurations, :handle_uri_prefix, :string

    add_column :data_files, :language, :string
    add_column :data_files, :rights_statement, :text, limit: 10000
    add_column :data_files, :access_rights_type, :string
    add_column :data_files, :access_rights_uri, :text, limit: 10000
    add_column :data_files, :research_centre_name, :string, limit: 80
    add_column :data_files, :hdl_handle, :string
    add_column :data_files, :physical_location, :string, :limit => 80
  end
end
