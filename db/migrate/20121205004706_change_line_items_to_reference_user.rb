class ChangeLineItemsToReferenceUser < ActiveRecord::Migration
  def up
    remove_column :line_items, :cart_id
    add_column :line_items, :user_id, :integer
  end

  def down
    add_column :line_items, :cart_id, :integer
    remove_column :line_items, :user_id
  end
end
