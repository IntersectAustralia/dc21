class AddDescriptionToPublishedCollections < ActiveRecord::Migration
  def change
    add_column :published_collections, :description, :text
  end
end
