class ChangeDatatypeOnTableFromStringToText < ActiveRecord::Migration
  def up
    change_column :related_websites, :url, :text, :limit => nil
    change_column :labels, :name, :text
    change_column :grant_numbers, :name, :text
    change_column :system_configurations, :research_librarians, :text
  end

  def down
    change_column :related_websites, :url, :string, :limit => 80
    change_column :labels, :name, :string
    change_column :grant_numbers, :name, :string
    change_column :system_configurations, :research_librarians, :string
  end
end
