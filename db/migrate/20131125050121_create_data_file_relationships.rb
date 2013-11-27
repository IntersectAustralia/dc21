class CreateDataFileRelationships < ActiveRecord::Migration
  def change
    create_table :data_file_relationships do |t|
      t.integer :parent_id
      t.integer :child_id

      t.timestamps
    end
  end
end
