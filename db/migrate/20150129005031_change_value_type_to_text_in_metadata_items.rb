class ChangeValueTypeToTextInMetadataItems < ActiveRecord::Migration
  def up
    change_column :metadata_items, :value, :text
  end

  def down
    change_column :metadata_items, :value, :string
  end
end
