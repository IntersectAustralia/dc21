class AddFrequencyToColumnDetails < ActiveRecord::Migration
  def up
    add_column :column_details, :frequency, :string
  end

  def down
    remove_column :column_details, :frequency
  end
end
