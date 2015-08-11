class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :language_name, null: false
      t.string :iso_code
      t.timestamps
    end

    add_column :data_files, :language_id, :integer
    add_column :system_configurations, :language_id, :integer
  end
end
