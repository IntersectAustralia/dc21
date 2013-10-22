class AddFieldsToSystemConfiguration < ActiveRecord::Migration
  def change
    add_column :system_configurations, :research_centre_name, :string, :limit => 80, :default => 'Hawkesbury Institute for the Environment', null: false
    add_column :system_configurations, :entity, :string, :limit => 80, :default => 'University of Western Sydney', null: false
    add_column :system_configurations, :address1, :string, :limit => 80, :default => 'Locked Bag 1797', null: true
    add_column :system_configurations, :address2, :string, :limit => 80, :default => 'Penrith NSW, 2751', null: true
    add_column :system_configurations, :address3, :string, :limit => 80, :default => 'Australia', null: true
    add_column :system_configurations, :telephone_number, :string, :limit => 80, :default => '+61 2 4570 1125', null: true
    add_column :system_configurations, :email, :string, :limit => 80, :default => 'hieinfo@lists.uws.edu.au', null: true
    add_column :system_configurations, :description, :string, :limit => 80, null: true
    add_column :system_configurations, :urls, :string, :limit => 80, :default => 'http://www.uws.edu.au/hie', null: true

    change_column :system_configurations, :name, :string, :default => 'HIEv'
  end
end
