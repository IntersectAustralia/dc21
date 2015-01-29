class AddFillValueToColumnDetail < ActiveRecord::Migration
  def up
    add_column :column_details, :fill_value, :string
  end

  def down
    remove_column :column_details, :fill_value
  end
end
