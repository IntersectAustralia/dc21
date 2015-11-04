class AddElectronicAddressNotesToSystemConfig < ActiveRecord::Migration
  def change
    add_column :system_configurations, :electronic_address_notes, :string, :default => 'Authorised users only'
  end
end
