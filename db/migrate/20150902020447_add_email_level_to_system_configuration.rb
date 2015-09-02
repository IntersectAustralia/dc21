class AddEmailLevelToSystemConfiguration < ActiveRecord::Migration
  def change
    add_column :system_configurations, :email_level, :string
  end
end
