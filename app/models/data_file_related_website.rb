class DataFileRelatedWebsite < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :related_website

  validates_presence_of :data_file
  validates_presence_of :related_website

end