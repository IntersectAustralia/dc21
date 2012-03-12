class CreateExperimentParameters < ActiveRecord::Migration
  def change
    create_table :experiment_parameters do |t|
      t.references :experiment
      t.references :parameter_category
      t.references :parameter_sub_category
      t.references :parameter_modification
      t.decimal :amount
      t.string :units
      t.string :comments

      t.timestamps
    end
    add_index :experiment_parameters, :parameter_category_id
    add_index :experiment_parameters, :parameter_sub_category_id
    add_index :experiment_parameters, :parameter_modification_id
  end
end
