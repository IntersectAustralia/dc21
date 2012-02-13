class AddParentExperimentToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :parent_experiment_id, :integer
  end
end
