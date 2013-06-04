class RemoveCartItemModel < ActiveRecord::Migration
  def up
  	drop_table :cart_items
  end

  def down
  end
end
