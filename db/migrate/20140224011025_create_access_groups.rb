class CreateAccessGroups < ActiveRecord::Migration
  def change
    create_table :access_groups do |t|
      t.string :name
      t.boolean :status, :default => true
      t.text :description

      t.timestamps
    end
  end
end
