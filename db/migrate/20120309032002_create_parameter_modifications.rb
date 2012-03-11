class CreateParameterModifications < ActiveRecord::Migration
  def change
    create_table :parameter_modifications do |t|
      t.string :name

      t.timestamps
    end
  end
end
