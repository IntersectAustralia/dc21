class DataFilesToLabelsTable < ActiveRecord::Migration
  def change
    create_table :data_files_labels, :id => false do |t|
      t.integer :data_file_id
      t.integer :label_id
    end
  end
end