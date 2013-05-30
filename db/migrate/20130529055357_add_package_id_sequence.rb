class AddPackageIdSequence < ActiveRecord::Migration
  def up
  	execute 'CREATE SEQUENCE package_id_seq;'
  end

  def down
  	execute 'DROP SEQUENCE IF EXISTS package_id_seq;'
  end
end
