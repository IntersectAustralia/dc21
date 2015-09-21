class AddAafFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :aaf_registered, :boolean, :default => false
  end
end
