class CreateRelatedWebsites < ActiveRecord::Migration
  def change
    create_table :related_websites do |t|
      t.integer :data_file_id
      t.string :url, limit: 80, null: false
      t.timestamps
    end
  end
end
