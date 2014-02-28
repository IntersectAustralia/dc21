class DatafileAccess < ActiveRecord::Base
  belongs_to :data_file
  belongs_to :access_group

  validates_presence_of :data_file
  validates_presence_of :access_group
end