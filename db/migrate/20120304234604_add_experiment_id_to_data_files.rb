class AddExperimentIdToDataFiles < ActiveRecord::Migration
  def change
    add_column :data_files, :experiment_id, :integer
  end
end
