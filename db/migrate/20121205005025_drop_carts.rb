class DropCarts < ActiveRecord::Migration
  def up
    drop_table :carts
  end

  def down
    create_table :carts do |t|
      t.timestamps
    end
  end
end
