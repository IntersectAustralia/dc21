class DataFileGrantNumber < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :grant_number

  validates_presence_of :data_file
  validates_presence_of :grant_number

end