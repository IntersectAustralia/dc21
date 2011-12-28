class CreateColumnMappings < ActiveRecord::Migration
  def change
    create_table :column_mappings do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
