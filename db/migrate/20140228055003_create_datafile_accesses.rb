class CreateDatafileAccesses < ActiveRecord::Migration
  def change
    create_table :datafile_accesses do |t|
      t.integer :data_file_id
      t.integer :access_group_id
      t.timestamps
    end
  end
end
