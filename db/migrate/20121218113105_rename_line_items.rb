class RenameLineItems < ActiveRecord::Migration
  def self.up
    if ActiveRecord::Base.connection.table_exists? 'line_items'
      if ActiveRecord::Base.connection.table_exists? 'cart_items'
        drop_table :cart_items
      end
      rename_table :line_items, :cart_items
    end
  end

 def self.down
    rename_table :cart_items, :line_items
 end
end