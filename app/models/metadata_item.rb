class MetadataItem < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :data_file_id
  validates_presence_of :key
  validates_presence_of :value

end
