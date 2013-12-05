class AddSrDetailsToSysConfig < ActiveRecord::Migration
  def change
    add_column :system_configurations, :sr_cloud_host, :string
    add_column :system_configurations, :sr_cloud_id, :string
    add_column :system_configurations, :sr_cloud_token, :string
  end
end
