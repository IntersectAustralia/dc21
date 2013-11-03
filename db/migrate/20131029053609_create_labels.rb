class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |l|
      l.string :name
    end
  end
end
