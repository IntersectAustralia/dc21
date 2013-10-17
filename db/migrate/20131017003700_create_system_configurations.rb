class CreateSystemConfigurations < ActiveRecord::Migration
  def change
    create_table :system_configurations do |t|
      t.string :name, :default => "Local System Name"

      t.timestamps
    end
  end
end
