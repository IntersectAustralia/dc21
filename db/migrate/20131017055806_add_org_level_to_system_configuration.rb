class AddOrgLevelToSystemConfiguration < ActiveRecord::Migration
  def change
    add_column :system_configurations, :level1, :string, :default => "Facility"
    add_column :system_configurations, :level1_plural, :string, :default => "Facilities"
    add_column :system_configurations, :level2, :string, :default => "Experiment"
    add_column :system_configurations, :level2_plural, :string, :default => "Experiments"
  end
end
