class AddOcrDetailsToSysConfig < ActiveRecord::Migration
  def change
    add_column :system_configurations, :ocr_cloud_host, :string, default: "cloud.ocrsdk.com"
    add_column :system_configurations, :ocr_cloud_id, :string
    add_column :system_configurations, :ocr_cloud_token, :string
  end
end
