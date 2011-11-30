class DataFile < ActiveRecord::Base

  validates_presence_of :filename
  validates_presence_of :format
  validates_presence_of :path
end
