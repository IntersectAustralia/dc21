class CreateExperimentForCodes < ActiveRecord::Migration
  def change
    create_table :experiment_for_codes do |t|
      t.references :experiment
      t.string :url
      t.string :name

      t.timestamps
    end
    add_index :experiment_for_codes, :experiment_id
  end
end
