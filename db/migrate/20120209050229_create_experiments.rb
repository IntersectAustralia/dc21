class CreateExperiments < ActiveRecord::Migration
  def change
    create_table :experiments do |t|
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.string :subject
      t.string :access_rights

      t.timestamps
    end
  end
end
