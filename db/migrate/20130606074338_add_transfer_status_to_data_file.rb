class AddTransferStatusToDataFile < ActiveRecord::Migration
  def change
    add_column :data_files, :transfer_status, :string
  end
end
