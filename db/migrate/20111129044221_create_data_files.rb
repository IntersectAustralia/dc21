class CreateDataFiles < ActiveRecord::Migration
  def change
    create_table :data_files do |t|
      t.string :filename
      t.string :format
      t.string :path

      t.timestamps
    end
  end
end
