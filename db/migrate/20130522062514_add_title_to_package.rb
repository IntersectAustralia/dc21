class AddTitleToPackage < ActiveRecord::Migration
  def change
  	add_column :data_files, :title, :text, :default => ""
  end
end
