class CreateParameterSubCategories < ActiveRecord::Migration
  def change
    create_table :parameter_sub_categories do |t|
      t.string :name
      t.references :parameter_category

      t.timestamps
    end
    add_index :parameter_sub_categories, :parameter_category_id
  end
end
