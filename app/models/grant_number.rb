class GrantNumber < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :grant_id

  attr_accessible :grant_id
end
