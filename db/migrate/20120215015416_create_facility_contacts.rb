class CreateFacilityContacts < ActiveRecord::Migration
  def change
    create_table :facility_contacts do |t|
      t.integer :facility_id
      t.integer :user_id
      t.boolean :primary, :default => false

      t.timestamps
    end
  end
end
