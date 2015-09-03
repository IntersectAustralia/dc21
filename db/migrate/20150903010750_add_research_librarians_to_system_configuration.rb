class AddResearchLibrariansToSystemConfiguration < ActiveRecord::Migration
  def change
    add_column :system_configurations, :research_librarians, :string, default: ""
  end
end
