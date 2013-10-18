class CreateSystemConfigurations < ActiveRecord::Migration
  def change
    create_table :system_configurations do |t|
      t.string :name, :default => "HIEv"

      t.timestamps
    end
  end
end
