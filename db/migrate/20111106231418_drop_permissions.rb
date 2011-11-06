class DropPermissions < ActiveRecord::Migration
  def up
    drop_table :roles_permissions
    drop_table :permissions
  end

  def down
    create_table :roles_permissions, :id => false do |t|
      t.references :role, :permission
    end

    create_table :permissions do |t|
      t.string :entity
      t.string :action
      t.timestamps
    end
  end

end
