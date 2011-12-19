class CreateColumnDetails < ActiveRecord::Migration
  def change
    create_table :column_details do |t|
      t.string :name
      t.string :unit
      t.string :data_type
      t.integer :position
      t.references :data_file

      t.timestamps
    end
    add_index :column_details, :data_file_id
  end
end
