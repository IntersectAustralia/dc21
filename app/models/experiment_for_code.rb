class ExperimentForCode < ActiveRecord::Base
  belongs_to :experiment

  validates_presence_of :url
  validates_presence_of :name
end
