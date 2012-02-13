class AddFacilityIdToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :facility_id, :integer
  end
end
