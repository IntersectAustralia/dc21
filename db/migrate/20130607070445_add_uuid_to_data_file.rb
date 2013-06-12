class AddUuidToDataFile < ActiveRecord::Migration
  def change
    add_column :data_files, :uuid, :string
  end
end
