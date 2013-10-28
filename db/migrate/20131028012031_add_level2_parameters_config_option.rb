class AddLevel2ParametersConfigOption < ActiveRecord::Migration
  def change
    add_column :system_configurations, :level2_parameters, :boolean, :default => true
  end
end
