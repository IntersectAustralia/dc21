class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.string :name
    end

    create_table :data_file_contributors, :id => false do |t|
      t.integer :data_file_id
      t.integer :contributor_id
    end
  end
end
