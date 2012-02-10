class Experiment < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :subject
  
end
