class AddAutoProcessingFieldsToSystemConfiguration < ActiveRecord::Migration
  def change
    add_column :system_configurations, :auto_ocr_on_upload, :boolean, :default => false
    add_column :system_configurations, :auto_ocr_regex, :text
    add_column :system_configurations, :auto_sr_on_upload, :boolean, :default => false
    add_column :system_configurations, :auto_sr_regex, :text
    add_column :system_configurations, :ocr_types, :text, :default => 'image/jpeg, image/png'
    add_column :system_configurations, :sr_types, :text, :default => 'audio/x-wav, audio/mpeg'
  end
end
