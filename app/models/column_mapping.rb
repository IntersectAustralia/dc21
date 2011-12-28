class ColumnMapping < ActiveRecord::Base

  validates_presence_of :code
  validates_presence_of :name
  validates_uniqueness_of :code
  
end
