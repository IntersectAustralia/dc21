class CreateRelatedWebsites < ActiveRecord::Migration
  def change
    create_table :related_websites do |t|
      t.string :url, limit: 80
    end

    create_table :data_file_related_websites, :id => false do |t|
      t.integer :data_file_id
      t.integer :related_website_id
    end
  end
end
