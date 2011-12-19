class ColumnDetail < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :data_file_id
  validates_presence_of :name

  default_scope order(:position)
end
