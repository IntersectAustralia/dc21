class ChangeExperimentParameterUnitsToReference < ActiveRecord::Migration
  def up
    remove_column :experiment_parameters, :units
    add_column :experiment_parameters, :parameter_unit_id, :integer
  end

  def down
    add_column :experiment_parameters, :units, :string
    remove_column :experiment_parameters, :parameter_unit_id, :integer
  end
end
