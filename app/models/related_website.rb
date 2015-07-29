class RelatedWebsite < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :url
  validates_length_of :url, maximum: 80

  attr_accessible :url
end
