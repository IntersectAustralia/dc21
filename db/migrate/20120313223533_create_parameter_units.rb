class CreateParameterUnits < ActiveRecord::Migration
  def change
    create_table :parameter_units do |t|
      t.string :name

      t.timestamps
    end
  end
end
