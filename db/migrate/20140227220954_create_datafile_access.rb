class CreateDatafileAccess < ActiveRecord::Migration
  def change
    create_table :datafile_access do |t|
      t.integer :datafile_id
      t.integer :access_group_id
      t.timestamps
    end
  end
end
