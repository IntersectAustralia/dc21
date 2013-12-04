class DataFileLabel < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :label

  validates_presence_of :data_file
  validates_presence_of :label


end