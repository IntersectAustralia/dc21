class Cart < ActiveRecord::Base
  has_many :line_items
   has_many :data_files, :through => :line_items

end
