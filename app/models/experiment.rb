class Experiment < ActiveRecord::Base

  belongs_to :facility
  
  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :subject
  validates_presence_of :facility_id

end
