class AddDashboardToSystemConfig < ActiveRecord::Migration
  def change
    add_column :system_configurations, :dashboard_contents, :text
  end
end
