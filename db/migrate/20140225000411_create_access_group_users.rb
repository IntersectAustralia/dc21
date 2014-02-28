class CreateAccessGroupUsers < ActiveRecord::Migration
  def change
    create_table :access_group_users do |t|
      t.integer :access_group_id
      t.integer :user_id
      t.boolean :primary, :default => false

      t.timestamps
    end
  end
end
