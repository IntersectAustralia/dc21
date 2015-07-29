class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :language_name, null: false
      t.string :iso_code
      t.timestamps
    end
  end
end
