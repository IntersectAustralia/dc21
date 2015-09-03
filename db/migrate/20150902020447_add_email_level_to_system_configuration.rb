class AddEmailLevelToSystemConfiguration < ActiveRecord::Migration
  def change
    add_column :system_configurations, :email_level, :string
    add_column :system_configurations, :research_librarians, :string, default: ""
  end
end
