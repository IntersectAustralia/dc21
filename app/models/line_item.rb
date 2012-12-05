class LineItem < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :user
  attr_accessible :user_id, :data_file_id

  validates_uniqueness_of :data_file_id, :scope => [:user_id]
end
