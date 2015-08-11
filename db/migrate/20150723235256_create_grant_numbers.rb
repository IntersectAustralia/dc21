class CreateGrantNumbers < ActiveRecord::Migration
  def change
    create_table :grant_numbers do |t|
      t.string :name
    end

    create_table :data_file_grant_numbers, :id => false do |t|
      t.integer :data_file_id
      t.integer :grant_number_id
    end
  end
end
