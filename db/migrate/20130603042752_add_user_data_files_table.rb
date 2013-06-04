class AddUserDataFilesTable < ActiveRecord::Migration
  def up
  	create_table :data_files_users, :id => false do |t|
		  t.references :data_file, :null => false
		  t.references :user, :null => false
		end

		add_index(:data_files_users, [:data_file_id, :user_id])
  end

  def down
  	drop_table :data_files_users
  end
end
