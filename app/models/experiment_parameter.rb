class ExperimentParameter < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :parameter_category
  belongs_to :parameter_sub_category
  belongs_to :parameter_modification

  validates_presence_of :experiment
  validates_presence_of :parameter_category
  validates_presence_of :parameter_sub_category
  validates_presence_of :parameter_modification
end
