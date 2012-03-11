class CreateParameterCategories < ActiveRecord::Migration
  def change
    create_table :parameter_categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
