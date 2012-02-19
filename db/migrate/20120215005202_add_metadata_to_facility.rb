class AddMetadataToFacility < ActiveRecord::Migration
  def change
    add_column :facilities, :description, :text
    add_column :facilities, :a_lat, :float
    add_column :facilities, :a_long, :float
    add_column :facilities, :b_lat, :float
    add_column :facilities, :b_long, :float
  end
end
