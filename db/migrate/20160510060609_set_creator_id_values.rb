class SetCreatorIdValues < ActiveRecord::Migration
  def up
    DataFile.update_all("creator_id=created_by_id")
    Package.update_all("creator_id=created_by_id")
  end

  def down
  end
end
