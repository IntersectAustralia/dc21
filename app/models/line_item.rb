class LineItem < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :cart
  attr_accessible :cart_id, :data_file_id

  validates_uniqueness_of :data_file_id, :scope => [:cart_id]
end
