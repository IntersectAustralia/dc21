class ChangeDefaultsForSystemConfig < ActiveRecord::Migration
  def up
    change_column_default :system_configurations, :name, "DIVER"
    change_column_default :system_configurations, :research_centre_name, "Enter your research centre name here"
    change_column_default :system_configurations, :entity, "Enter your institution name here"
    change_column_default :system_configurations, :address1, "Enter your address"
    change_column_default :system_configurations, :address2, ""
    change_column_default :system_configurations, :address3, ""
    change_column_default :system_configurations, :telephone_number, ""
    change_column_default :system_configurations, :email, ""
    change_column_default :system_configurations, :description, ""
    change_column_default :system_configurations, :urls, ""
  end

  def down
    change_column_default :system_configurations, :name, "DIVER"
    change_column_default :system_configurations, :research_centre_name, "Enter your research centre name here"
    change_column_default :system_configurations, :entity, "Enter your institution name here"
    change_column_default :system_configurations, :address1, "Enter your address"
    change_column_default :system_configurations, :address2, ""
    change_column_default :system_configurations, :address3, ""
    change_column_default :system_configurations, :telephone_number, ""
    change_column_default :system_configurations, :email, ""
    change_column_default :system_configurations, :description, ""
    change_column_default :system_configurations, :urls, ""
  end
end
