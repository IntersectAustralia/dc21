class CreateGrantNumbers < ActiveRecord::Migration
  def change
    create_table :grant_numbers do |t|
      t.integer :data_file_id
      t.string :grant_id, null: false
      t.timestamps
    end
  end
end
