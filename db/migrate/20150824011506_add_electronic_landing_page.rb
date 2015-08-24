class AddElectronicLandingPage < ActiveRecord::Migration
  def change
    add_column :system_configurations, :electronic_landing_page_title, :string, :default => "Enter the title of your landing page"
  end
end
