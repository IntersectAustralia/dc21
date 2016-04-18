class DataFileContributor < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :contributor

  validates_presence_of :data_file
  validates_presence_of :contributor

end