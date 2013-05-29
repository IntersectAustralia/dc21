class AddPackageIdSequence < ActiveRecord::Migration
  def up

  	execute 'CREATE SEQUENCE package_id_seq;'
  	add_column :data_files, :package_id, :integer
  	execute "ALTER TABLE data_files ALTER COLUMN package_id SET DEFAULT NEXTVAL('package_id_seq') - 1;"

  end

  def down

  	remove_column :data_files, :package_id
  	execute 'DROP SEQUENCE IF EXISTS package_id_seq;'
  end
end
